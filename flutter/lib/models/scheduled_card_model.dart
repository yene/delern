import 'dart:core';
import 'dart:math';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/flutter/clock.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'scheduled_card_model.g.dart';

abstract class ScheduledCardModel
    implements
        Built<ScheduledCardModel, ScheduledCardModelBuilder>,
        KeyedListItem {
  @visibleForTesting
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

  /// A shuffling generator to mix cards in the future via repeatAt (or mix new
  /// reversed cards into the past).
  static final _shuffleRandom = Random();

  /// Compute the base value for [repeatAt]; thet is, one without delay based on
  /// card level. If [newCard] is set, [shuffle] will attenuate the date
  /// backwards (effectively putting card into learning queue), otherwise it
  /// will attenuate the date forward (shuffling cards to learn in future).
  static DateTime computeRepeatAtBase({
    @required bool newCard,
    @required bool shuffle,
  }) {
    final now = clock.now();

    if (!shuffle) {
      return now;
    }

    if (newCard) {
      return now.add(Duration(days: -_shuffleRandom.nextInt(365)));
    }
    return now.add(Duration(hours: _shuffleRandom.nextInt(3)));
  }

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
      ..repeatAt = computeRepeatAtBase(
        newCard: false,
        shuffle: true,
      ).add(levelDurations[newLevel]));
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
