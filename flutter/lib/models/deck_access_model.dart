import 'dart:async';
import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

part 'deck_access_model.g.dart';

class AccessType extends EnumClass implements Comparable<AccessType> {
  static Serializer<AccessType> get serializer => _$accessTypeSerializer;

  static const AccessType owner = _$owner;

  /// "write" implies "read".
  static const AccessType write = _$write;

  static const AccessType read = _$read;

  const AccessType._(String name) : super(name);

  static BuiltSet<AccessType> get values => _$values;
  static AccessType valueOf(String name) => _$valueOf(name);

  // In Dart, default Set implementation is LinkedHashSet, which is ordered.
  // Convert it to a List here to make the values indexable:
  // https://github.com/google/built_value.dart/issues/693.
  static final BuiltList<AccessType> orderedValues = BuiltList.of(_$values);

  @override
  int compareTo(AccessType other) =>
      orderedValues.indexOf(this).compareTo(orderedValues.indexOf(other));
}

abstract class DeckAccessModel
    implements Built<DeckAccessModel, DeckAccessModelBuilder>, KeyedListItem {
  /// [DeckAccessModel.key] is uid of the user whose access it holds.
  @nullable
  String get key;

  @nullable
  String get deckKey;
  @nullable
  AccessType get access;
  @nullable
  String get email;

  /// Display Name is populated by database, can be null.
  @nullable
  String get displayName;

  /// Photo URL is populated by database, can be null.
  @nullable
  String get photoUrl;

  static Serializer<DeckAccessModel> get serializer =>
      _$deckAccessModelSerializer;

  factory DeckAccessModel([void Function(DeckAccessModelBuilder) updates]) =
      _$DeckAccessModel;
  DeckAccessModel._();

  static DeckAccessModel fromSnapshot({
    @required String key,
    @required String deckKey,
    @required Map value,
  }) {
    if (value == null) {
      return (DeckAccessModelBuilder()..deckKey = deckKey).build();
    }
    return serializers
        .deserializeWith(DeckAccessModel.serializer, value)
        .rebuild((b) => b
          ..deckKey = deckKey
          ..key = key);
  }

  static Stream<DeckAccessModel> get(
          {@required String deckKey, @required String key}) =>
      FirebaseDatabase.instance
          .reference()
          .child('deck_access')
          .child(deckKey)
          .child(key)
          .onValue
          .map((evt) => DeckAccessModel.fromSnapshot(
              key: key, deckKey: deckKey, value: evt.snapshot.value));
}

class DeckAccessListAccessor extends DataListAccessor<DeckAccessModel> {
  final String deckKey;

  DeckAccessListAccessor({@required this.deckKey})
      : super(FirebaseDatabase.instance
            .reference()
            .child('deck_access')
            .child(deckKey)
              ..orderByKey());

  @override
  DeckAccessModel parseItem(String key, value) =>
      DeckAccessModel.fromSnapshot(key: key, deckKey: deckKey, value: value);
}
