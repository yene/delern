import 'dart:async';
import 'dart:core';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/models/base/database_observable_list.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

part 'card_model.g.dart';

abstract class CardModel
    implements Built<CardModel, CardModelBuilder>, KeyedListItem {
  @nullable
  String get deckKey;
  @nullable
  String get key;
  @nullable
  String get front;
  @nullable
  String get back;
  @nullable
  DateTime get createdAt;

  static Serializer<CardModel> get serializer => _$cardModelSerializer;

  factory CardModel([void Function(CardModelBuilder) updates]) = _$CardModel;
  CardModel._();

  static CardModel fromSnapshot({
    @required String deckKey,
    @required String key,
    @required Map value,
  }) {
    if (value == null) {
      return (CardModelBuilder()..deckKey = deckKey).build();
    }
    return serializers
        .deserializeWith(CardModel.serializer, value)
        .rebuild((b) => b
          ..deckKey = deckKey
          ..key = key);
  }

  static Stream<CardModel> get(
          {@required String deckKey, @required String key}) =>
      FirebaseDatabase.instance
          .reference()
          .child('cards')
          .child(deckKey)
          .child(key)
          .onValue
          .map((evt) => CardModel.fromSnapshot(
              deckKey: deckKey, key: key, value: evt.snapshot.value));

  static DatabaseObservableList<CardModel> getList(
          {@required String deckKey}) =>
      DatabaseObservableList(
          query: FirebaseDatabase.instance
              .reference()
              .child('cards')
              .child(deckKey)
              .orderByKey(),
          snapshotParser: (key, value) => CardModel.fromSnapshot(
                deckKey: deckKey,
                key: key,
                value: value,
              ));
}

class CardModelListAccessor extends DataListAccessor<CardModel> {
  final String deckId;

  CardModelListAccessor(this.deckId)
      : super(
            FirebaseDatabase.instance.reference().child('cards').child(deckId));

  @override
  CardModel parseItem(String key, value) =>
      CardModel.fromSnapshot(deckKey: deckId, key: key, value: value);
}
