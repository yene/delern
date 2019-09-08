import 'dart:async';
import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/models/base/database_observable_list.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

part 'deck_access_model.g.dart';

class AccessType extends EnumClass {
  static Serializer<AccessType> get serializer => _$accessTypeSerializer;

  static const AccessType owner = _$owner;
  static const AccessType write = _$write;
  static const AccessType read = _$read;

  const AccessType._(String name) : super(name);

  static BuiltSet<AccessType> get values => _$values;
  static AccessType valueOf(String name) => _$valueOf(name);

  // In Dart, default Set implementation is LinkedHashSet, which is ordered.
  // Convert it to a List here to make the values indexable.
  static final List<AccessType> orderedValues = _$values.toList();

  int compareTo(AccessType other) =>
      orderedValues.indexOf(this).compareTo(orderedValues.indexOf(other));
}

class DeckAccessModel implements KeyedListItem, Model {
  /// DeckAccessModel key is uid of the user whose access it holds.
  String key;

  String deckKey;
  AccessType access;
  String email;

  /// Display Name is populated by database, can be null.
  String get displayName => _displayName;
  String _displayName;

  /// Photo URL is populated by database, can be null.
  String get photoUrl => _photoUrl;
  String _photoUrl;

  DeckAccessModel({@required this.deckKey}) : assert(deckKey != null);

  DeckAccessModel._fromSnapshot({
    @required this.key,
    @required this.deckKey,
    @required Map value,
  })  : assert(key != null),
        assert(deckKey != null) {
    if (value == null) {
      key = null;
      return;
    }
    _displayName = value['displayName'];
    _photoUrl = value['photoUrl'];
    email = value['email'];
    access = AccessType.valueOf(value['access']);
  }

  static DatabaseObservableList<DeckAccessModel> getList(
          {@required String deckKey}) =>
      DatabaseObservableList(
          query: FirebaseDatabase.instance
              .reference()
              .child('deck_access')
              .child(deckKey)
              .orderByKey(),
          snapshotParser: (key, value) => DeckAccessModel._fromSnapshot(
              key: key, deckKey: deckKey, value: value));

  static Stream<DeckAccessModel> get(
          {@required String deckKey, @required String key}) =>
      FirebaseDatabase.instance
          .reference()
          .child('deck_access')
          .child(deckKey)
          .child(key)
          .onValue
          .map((evt) => DeckAccessModel._fromSnapshot(
              key: key, deckKey: deckKey, value: evt.snapshot.value));
}
