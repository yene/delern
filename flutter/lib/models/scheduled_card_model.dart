import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/flutter/clock.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

part 'scheduled_card_model.g.dart';

abstract class ScheduledCardModel
    implements
        Built<ScheduledCardModel, ScheduledCardModelBuilder>,
        KeyedListItem {
  static const levelDurations = [
    Duration(hours: 4),
    Duration(days: 1),
    Duration(days: 2),
    Duration(days: 5),
    Duration(days: 14),
    Duration(days: 30),
    Duration(days: 60),
  ];

  @nullable
  String get deckKey;

  /// [ScheduledCardModel.key] is the key of the card that it represents.
  @nullable
  @override
  String get key;

  int get level;
  DateTime get repeatAt;

  static Serializer<ScheduledCardModel> get serializer =>
      _$scheduledCardModelSerializer;

  factory ScheduledCardModel(
          [void Function(ScheduledCardModelBuilder) updates]) =
      _$ScheduledCardModel;
  ScheduledCardModel._();

  static ScheduledCardModel fromSnapshot({
    @required String key,
    @required String deckKey,
    @required Map value,
  }) {
    // Below is a hack to translate legacy values (i.e. strings starting with
    // 'L') into something that BuiltValue understands.
    var levelString = value['level'].toString();
    if (levelString.startsWith('L')) {
      levelString = levelString.substring(1);
    }
    try {
      value['level'] = int.parse(levelString);
    } on FormatException catch (e, stackTrace) {
      error_reporting.report(e, stackTrace: stackTrace);
      value['level'] = 0;
    }

    return serializers
        .deserializeWith(ScheduledCardModel.serializer, value)
        .rebuild((b) => b
          ..deckKey = deckKey
          ..key = key);
  }

  // A jutter used to calculate diverse next scheduled time for a card.
  static final _jitterRandom = Random();
  Duration _newJitter() => Duration(minutes: _jitterRandom.nextInt(180));

  static Stream<ScheduledCardModel> next(User user, DeckModel deck) =>
      FirebaseDatabase.instance
          .reference()
          .child('learning')
          .child(user.uid)
          .child(deck.key)
          .orderByChild('repeatAt')
          // Need at least 2 because of how Firebase local cache works.
          // After we pick up the latest ScheduledCard and update it, it
          // triggers onValue twice: once with the updated ScheduledCard (most
          // likely triggered by local cache) and the second time with the next
          // ScheduledCard (fetched from the server). Doing keepSynced(true) on
          // the learning tree fixes this because local cache gets all entries.
          .limitToFirst(2)
          .onValue
          .transform(
              StreamTransformer.fromHandlers(handleData: (event, sink) async {
        if (event.snapshot.value == null) {
          // The deck is empty. Should we offer the user to re-sync?
          sink.close();
          return;
        }

        // TODO(dotdoom): remove sorting once Flutter Firebase issue is fixed.
        // Workaround for https://github.com/flutter/flutter/issues/19389.
        final List<MapEntry> allEntries = event.snapshot.value.entries.toList();
        final latestScheduledCard = (allEntries
              ..sort((s1, s2) {
                final int repeatAtComparison =
                    s1.value['repeatAt'].compareTo(s2.value['repeatAt']);
                // Sometimes repeatAt of 2 cards may be the same, which
                // will result in unstable order. Most often this is
                // happening to the newly added cards, which have
                // repeatAt = 0.
                // We mimic Firebase behavior here, which falls back to
                // sorting lexicographically by key.
                // TODO(dotdoom): do not set repeatAt = 0?
                if (repeatAtComparison == 0) {
                  return s1.key.compareTo(s2.key);
                }
                return repeatAtComparison;
              }))
            .first;

        final scheduledCard = ScheduledCardModel.fromSnapshot(
            key: latestScheduledCard.key,
            deckKey: deck.key,
            value: latestScheduledCard.value);

        if (deck.cards.getItem(latestScheduledCard.key).value == null) {
          // Card has been removed but we still have ScheduledCard for it.
          debugPrint('Removing dangling ScheduledCard ${scheduledCard.key}');
          unawaited(user.cleanupDanglingScheduledCard(scheduledCard));
          return;
        }

        sink.add(scheduledCard);
      }));

  ScheduledCardModel answer({@required bool knows}) {
    var newLevel = level;

    final now = clock.now();
    if (knows && (repeatAt == now || repeatAt.isBefore(now))) {
      newLevel = min(level + 1, levelDurations.length - 1);
    }
    if (!knows) {
      newLevel = 0;
    }

    return rebuild((b) => b
      ..level = newLevel
      ..repeatAt = now.toUtc().add(levelDurations[newLevel] + _newJitter()));
  }
}

class ScheduledCardModelListAccessor
    extends DataListAccessor<ScheduledCardModel> {
  final String uid;
  final String deckKey;

  ScheduledCardModelListAccessor({this.uid, this.deckKey})
      : super(FirebaseDatabase.instance
            .reference()
            .child('learning')
            .child(uid)
            .child(deckKey));

  @override
  ScheduledCardModel parseItem(String key, dynamic value) =>
      ScheduledCardModel.fromSnapshot(key: key, deckKey: deckKey, value: value);
}
