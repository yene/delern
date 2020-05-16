import 'dart:async';
import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/models/base/clock.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'deck_model.g.dart';

class DeckType extends EnumClass {
  static Serializer<DeckType> get serializer => _$deckTypeSerializer;

  @BuiltValueEnumConst(wireName: 'BASIC')
  static const DeckType basic = _$basic;

  @BuiltValueEnumConst(wireName: 'GERMAN')
  static const DeckType german = _$german;

  @BuiltValueEnumConst(wireName: 'SWISS')
  static const DeckType swiss = _$swiss;

  const DeckType._(String name) : super(name);

  static BuiltSet<DeckType> get values => _$values;
  static DeckType valueOf(String name) => _$valueOf(name);
}

abstract class DeckModel
    implements Built<DeckModel, DeckModelBuilder>, KeyedListItem {
  @nullable
  @override
  String get key;
  @nullable
  String get name;
  @nullable
  bool get markdown;
  @BuiltValueField(wireName: 'deckType')
  DeckType get type;
  @nullable
  bool get accepted;
  @nullable
  AccessType get access;
  DateTime get lastSyncAt;
  @nullable
  String get category;
  @nullable
  BuiltSet<String> get latestTagSelection;

  @nullable
  @BuiltValueField(compare: false, serialize: false)
  DataListAccessor<CardModel> get cards;
  @nullable
  @BuiltValueField(compare: false, serialize: false)
  DataListAccessor<ScheduledCardModel> get scheduledCards;
  @nullable
  @BuiltValueField(compare: false, serialize: false)
  _ScheduledCardsDueCounter get numberOfCardsDue;
  @nullable
  @BuiltValueField(compare: false, serialize: false)
  DataListAccessor<DeckAccessModel> get usersAccess;

  static Serializer<DeckModel> get serializer => _$deckModelSerializer;

  factory DeckModel([void Function(DeckModelBuilder) updates]) = _$DeckModel;
  DeckModel._();

  static void _initializeBuilder(DeckModelBuilder b) => b
    ..lastSyncAt = DateTime.fromMillisecondsSinceEpoch(0)
    ..markdown = true
    ..access = AccessType.owner
    ..type = DeckType.basic
    ..accepted = true;

  /// A set of tags from all cards, sorted alphabetically.
  StreamWithValue<BuiltSet<String>> get tags =>
      cards?.map<BuiltSet<String>>((cards) => BuiltSet<String>.of(
          cards.expand((card) => card.tags).toList()..sort()));

  /// Yield one [ScheduledCardModel] and then yield one every time [answers]
  /// stream generates an event, excluding the cards which keys are provided on
  /// [answers]. If [ScheduledCardModel] has a corresponding [CardModel], it
  /// must have non-empty intersection of [CardModel.tags] with [tags], unless
  /// [tags] is empty.
  Stream<ScheduledCardModel> startLearningSession({
    @required Stream<String> answers,
    @required BuiltSet<String> tags,
  }) async* {
    final cardsAnswered = <String>{};
    List<ScheduledCardModel> unansweredMatchingCards() =>
        (scheduledCards.value.where((scheduledCard) {
          if (!cardsAnswered.contains(scheduledCard.key)) {
            if (tags.isEmpty) {
              return true;
            }
            final cardsSnapshot = cards.value;
            final cardIndex = cardsSnapshot.indexOfKey(scheduledCard.key);
            if (cardIndex < 0) {
              // If we can't find card (yet?), let it through and UI will
              // figure it out (most likely clean up an orphan).
              return true;
            }
            return cardsSnapshot[cardIndex].tags.intersection(tags).isNotEmpty;
          }
          return false;
        }).toList()
          ..sort((c1, c2) => c1.repeatAt.compareTo(c2.repeatAt)));

    final initialCards = unansweredMatchingCards();
    if (initialCards.isEmpty) {
      return;
    }
    yield initialCards.first;

    await for (final cardKey in answers) {
      cardsAnswered.add(cardKey);
      final cardsLeft = unansweredMatchingCards();
      if (cardsLeft.isEmpty) {
        break;
      }
      yield cardsLeft.first;
    }
  }
}

class _ScheduledCardsDueCounter implements StreamWithValue<int> {
  final _counter = StreamController<int>.broadcast();
  Timer _refreshTimer;
  int _latestValue;

  _ScheduledCardsDueCounter(ListAccessor<ScheduledCardModel> scheduledCards) {
    // We don't need to cancel this subscription because lifecycle of
    // _ScheduledCardsDueCounter is the same as that of [scheduledCards] within
    // DeckModel, and ListAccessor will close its streams, cancelling any
    // active subscriptions (and also closing _counter StreamController).
    scheduledCards.updates
        .listen(_findCardsAndResetTimer, onDone: _counter.close);
    if (scheduledCards.loaded) {
      _findCardsAndResetTimer(scheduledCards.value);
    }
  }

  @override
  bool get loaded => _latestValue != null;

  @override
  Stream<int> get updates => _counter.stream;

  @override
  int get value => _latestValue;

  /// A delay between next scheduled card and our timer trigger, to avoid time
  /// computation uncertainties, and also avoid timer restart churn if multiple
  /// cards come with a small interval between them.
  static const _nextCardTimerDelay = Duration(seconds: 30);

  void _findCardsAndResetTimer(BuiltList<ScheduledCardModel> allCards) {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    final now = clock.now();
    final notYetDue = allCards.where((sc) => sc.repeatAt.isAfter(now));

    if (notYetDue.isNotEmpty) {
      final nextCardForDuePool = notYetDue
          .reduce((m1, m2) => m1.repeatAt.isBefore(m2.repeatAt) ? m1 : m2);
      debugPrint('Next card to add to due pool is ${nextCardForDuePool.key} '
          'for deck ${nextCardForDuePool.deckKey}: '
          'at ${nextCardForDuePool.repeatAt}');
      _refreshTimer = Timer(
          nextCardForDuePool.repeatAt.difference(now) + _nextCardTimerDelay,
          () => _findCardsAndResetTimer(allCards));
    }

    _counter.add(_latestValue = allCards.length - notYetDue.length);
  }

  void close() => _refreshTimer?.cancel();
}

class DeckModelListAccessor extends DataListAccessor<DeckModel> {
  final String uid;

  DeckModelListAccessor(this.uid)
      : super(FirebaseDatabase.instance.reference().child('decks').child(uid));

  @override
  DeckModel parseItem(String key, dynamic value) =>
      serializers.deserializeWith(DeckModel.serializer, value).rebuild((d) => d
        ..key = key
        ..cards = CardModelListAccessor(key)
        ..scheduledCards =
            ScheduledCardModelListAccessor(uid: uid, deckKey: key)
        ..usersAccess = DeckAccessListAccessor(deckKey: key)
        ..numberOfCardsDue = _ScheduledCardsDueCounter(d.scheduledCards));

  @override
  DeckModel updateItem(DeckModel previous, dynamic value) =>
      serializers.deserializeWith(DeckModel.serializer, value).rebuild((d) => d
        ..key = previous.key
        ..cards = previous.cards
        ..scheduledCards = previous.scheduledCards
        ..usersAccess = previous.usersAccess
        ..numberOfCardsDue = previous.numberOfCardsDue);

  @override
  void disposeItem(DeckModel item) => item
    ..cards.close()
    ..scheduledCards.close()
    ..usersAccess.close()
    ..numberOfCardsDue.close();
}
