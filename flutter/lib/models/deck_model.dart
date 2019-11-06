import 'dart:async';
import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
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
  String get key;
  @nullable
  String get name;
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
  ListAccessor<CardModel> get cards;
  @nullable
  ListAccessor<ScheduledCardModel> get scheduledCards;

  static Serializer<DeckModel> get serializer => _$deckModelSerializer;

  factory DeckModel([void Function(DeckModelBuilder) updates]) = _$DeckModel;
  DeckModel._();

  static DeckModel fromSnapshot({
    @required String key,
    @required Map value,
  }) {
    if (value == null) {
      return DeckModelBuilder().build();
    }
    return serializers
        .deserializeWith(DeckModel.serializer, value)
        .rebuild((b) => b..key = key);
  }

  static Stream<DeckModel> get({@required String uid, @required String key}) =>
      FirebaseDatabase.instance
          .reference()
          .child('decks')
          .child(uid)
          .child(key)
          .onValue
          .map((evt) => DeckModel.fromSnapshot(
                key: key,
                value: evt.snapshot.value,
              ));
}

abstract class DeckModelBuilder
    implements Builder<DeckModel, DeckModelBuilder> {
  String key;
  String name;
  bool markdown = true;
  DeckType type = DeckType.basic;
  bool accepted = true;
  AccessType access;
  DateTime lastSyncAt = DateTime.fromMillisecondsSinceEpoch(0);
  String category;
  @nullable
  ListAccessor<CardModel> cards;
  @nullable
  ListAccessor<ScheduledCardModel> scheduledCards;
  factory DeckModelBuilder() = _$DeckModelBuilder;
  DeckModelBuilder._();
}

class DeckModelListAccessor extends DataListAccessor<DeckModel> {
  final String uid;

  DeckModelListAccessor(this.uid)
      : super(FirebaseDatabase.instance.reference().child('decks').child(uid));

  @override
  DeckModel parseItem(String key, value) {
    final initDeck = DeckModel.fromSnapshot(key: key, value: value);
    return initDeck.rebuild((d) => d
      ..cards = CardModelListAccessor(d.key)
      ..scheduledCards =
          ScheduledCardModelListAccessor(uid: uid, deckKey: d.key));
  }

  @override
  DeckModel updateItem(DeckModel previous, String key, value) {
    final initDeck = DeckModel.fromSnapshot(key: key, value: value);
    return initDeck.rebuild((d) => d
      ..cards = previous.cards
      ..scheduledCards = previous.scheduledCards);
  }

  @override
  void disposeItem(DeckModel item) =>
      item..cards.close()..scheduledCards.close();
}
