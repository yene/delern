import 'dart:async';
import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/models/base/database_observable_list.dart';
import 'package:delern_flutter/models/base/model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

part 'deck_model.g.dart';

class DeckType extends EnumClass {
  static Serializer<DeckType> get serializer => _$deckTypeSerializer;

  static const DeckType basic = _$basic;
  static const DeckType german = _$german;
  static const DeckType swiss = _$swiss;

  const DeckType._(String name) : super(name);

  static BuiltSet<DeckType> get values => _$values;
  static DeckType valueOf(String name) => _$valueOf(name);
}

class DeckModel implements Model {
  String key;
  String name;
  bool markdown;
  DeckType type;
  bool accepted;
  AccessType access;
  DateTime lastSyncAt;
  String category;

  DeckModel() {
    lastSyncAt = DateTime.fromMillisecondsSinceEpoch(0);
    markdown = false;
    type = DeckType.basic;
    accepted = true;
  }

  // We expect this to be called often and optimize for performance.
  DeckModel.copyFrom(DeckModel other)
      : key = other.key,
        name = other.name,
        markdown = other.markdown,
        type = other.type,
        accepted = other.accepted,
        lastSyncAt = other.lastSyncAt,
        category = other.category,
        access = other.access;

  DeckModel._fromSnapshot({
    @required this.key,
    @required Map value,
  }) : assert(key != null) {
    if (value == null) {
      key = null;
      return;
    }
    name = value['name'];
    markdown = value['markdown'] ?? false;
    type = value.containsKey('deckType')
        ? DeckType.valueOf(value['deckType'].toLowerCase())
        : DeckType.basic;
    accepted = value['accepted'] ?? false;
    lastSyncAt = DateTime.fromMillisecondsSinceEpoch(value['lastSyncAt'] ?? 0);
    category = value['category'];
    access = value.containsKey('access')
        ? AccessType.valueOf(value['access'])
        : null;
  }

  static Stream<DeckModel> get({@required String uid, @required String key}) =>
      FirebaseDatabase.instance
          .reference()
          .child('decks')
          .child(uid)
          .child(key)
          .onValue
          .map((evt) => DeckModel._fromSnapshot(
                key: key,
                value: evt.snapshot.value,
              ));

  static DatabaseObservableList<DeckModel> getList({@required String uid}) {
    FirebaseDatabase.instance
        .reference()
        .child('decks')
        .child(uid)
        .keepSynced(true);

    return DatabaseObservableList(
        query: FirebaseDatabase.instance
            .reference()
            .child('decks')
            .child(uid)
            .orderByKey(),
        snapshotParser: (key, value) {
          _keepDeckSynced(uid, key);
          return DeckModel._fromSnapshot(key: key, value: value);
        });
  }

  static void _keepDeckSynced(String uid, String deckId) {
    // Install a background listener on Card. The listener is cancelled
    // automatically when the deck is deleted or un-shared, because the security
    // rules will not allow to listen to that node anymore.
    // ScheduledCard is synced within ScheduledCardsBloc.
    // TODO(dotdoom): these listeners are gone when we delete the last card
    //                (Firebase says "Permission denied"). What can we do?
    FirebaseDatabase.instance
        .reference()
        .child('cards')
        .child(deckId)
        .keepSynced(true);
  }
}
