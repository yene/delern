import 'dart:async';

import 'package:async/async.dart';
import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/list_change_record.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  StreamController<Event> onChildAdded;
  StreamController<Event> onChildRemoved;
  StreamController<Event> onChildChanged;
  DatabaseReference dbReference;

  setUp(() {
    onChildAdded = StreamController<Event>();
    onChildChanged = StreamController<Event>();
    onChildRemoved = StreamController<Event>();

    dbReference = MockDatabaseReference();
    when(dbReference.path).thenReturn('/objects');
    when(dbReference.onChildAdded).thenAnswer((_) => onChildAdded.stream);
    when(dbReference.onChildRemoved).thenAnswer((_) => onChildRemoved.stream);
    when(dbReference.onChildChanged).thenAnswer((_) => onChildChanged.stream);
    when(dbReference.once()).thenAnswer((_) => Future.value(FakeSnapshot()));
  });

  tearDown(() async {
    await onChildAdded.close();
    await onChildRemoved.close();
    await onChildChanged.close();
  });

  test('ListAccessor (initial read error)', () async {
    when(dbReference.once())
        .thenAnswer((_) => Future.error(const AccessDeniedError()));

    final accessor = MyListAccessor(dbReference);
    try {
      await accessor.events.first;
      throw Exception('This should have failed!');
    } on DatabaseReadException catch (e) {
      expect(e.code, 13);
      expect(e.message, contains('Access denied'));
      expect(e.details, contains('READ'));
      expect(e.path, '/objects');
    }
  });

  test('ListAccessor (first set)', () async {
    // Since there's an unavoidable async gap between setUp and first test, we
    // extract tests for the very first accessor.updates and accessor.events
    // stream events (coming from dbReference.once) here.
    final accessor = MyListAccessor(dbReference);

    expect(
        accessor.updates,
        emitsInOrder(<dynamic>[
          BuiltList.of(<MyModel>[]),
        ]));
    expectListChangeRecord<MyModel>(
      await accessor.events.first,
      [],
      0,
      removed: [],
    );

    accessor.close();
  });

  test('ListAccessor getItem (before loading)', () async {
    final item = MyListAccessor(dbReference).getItem('test');
    expect(item.loaded, false);
    await allEventsDelivered();
    expect(item.loaded, true);
  });

  group('ListAccessor (subsequent changes)', () {
    MyListAccessor accessor;

    setUp(() {
      accessor = MyListAccessor(dbReference);
    });

    tearDown(() {
      accessor.close();
      expect(accessor.value, isEmpty);
    });

    group('updates', () {
      test('add then remove', () async {
        final updates = StreamQueue(accessor.updates);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expect(await updates.next, BuiltList.of([const MyModel(key: '1')]));
        onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expect(await updates.next, BuiltList.of(<MyModel>[]));
      });

      test('add then add', () async {
        final updates = StreamQueue(accessor.updates);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expect(await updates.next, BuiltList.of([const MyModel(key: '1')]));
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '2')));
        expect(
          await updates.next,
          BuiltList.of([const MyModel(key: '1'), const MyModel(key: '2')]),
        );
      });

      test('add then update', () async {
        final updates = StreamQueue(accessor.updates);
        onChildAdded
            .add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '3')));
        expect(
          await updates.next,
          BuiltList.of([const MyModel(key: '1', value: '3')]),
        );
        onChildChanged
            .add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '1')));
        expect(
          await updates.next,
          BuiltList.of([const MyModel(key: '1', value: '1')]),
        );
      });

      test('add then error', () async {
        final updates = StreamQueue(accessor.updates);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expect(await updates.next, BuiltList.of([const MyModel(key: '1')]));
        onChildAdded.addError(const AccessDeniedError());
        try {
          await updates.next;
          throw Exception('This should have failed!');
        } on DatabaseReadException catch (e) {
          expect(e.code, 13);
          expect(e.message, contains('Access denied'));
          expect(e.details, contains('READ'));
          expect(e.path, '/objects');
        }
        expect(() => updates.next, throwsA(const TypeMatcher<StateError>()));
      });
    });

    group('value', () {
      test('add then remove', () async {
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        await allEventsDelivered();
        expect(accessor.value, BuiltList.of([const MyModel(key: '1')]));
        onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        await allEventsDelivered();
        expect(accessor.value, BuiltList.of(<MyModel>[]));
      });

      test('add then add', () async {
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        await allEventsDelivered();
        expect(accessor.value, BuiltList.of([const MyModel(key: '1')]));
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '2')));
        await allEventsDelivered();
        expect(accessor.value,
            BuiltList.of([const MyModel(key: '1'), const MyModel(key: '2')]));
      });

      test('add then update', () async {
        onChildAdded
            .add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '3')));
        await allEventsDelivered();
        expect(accessor.value,
            BuiltList.of([const MyModel(key: '1', value: '3')]));
        onChildChanged
            .add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '1')));
        await allEventsDelivered();
        expect(accessor.value,
            BuiltList.of([const MyModel(key: '1', value: '1')]));
      });

      test('add then error', () async {
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        await allEventsDelivered();
        expect(accessor.value, BuiltList.of([const MyModel(key: '1')]));
        onChildAdded.addError(const AccessDeniedError());
        await allEventsDelivered();
        expect(accessor.value, isEmpty);
      });

      test('initial (empty)', () async {
        expect(accessor.value, const Iterable<void>.empty());
      });
    });

    group('events', () {
      test('add then remove', () async {
        final events = StreamQueue(accessor.events);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expectListChangeRecord<MyModel>(
            await events.next, [const MyModel(key: '1')], 0,
            removed: [], addedCount: 1);
        onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expectListChangeRecord<MyModel>(await events.next, [], 0,
            removed: [const MyModel(key: '1')]);
      });

      test('add then add', () async {
        final events = StreamQueue(accessor.events);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expectListChangeRecord<MyModel>(
            await events.next, [const MyModel(key: '1')], 0,
            removed: [], addedCount: 1);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '2')));
        expectListChangeRecord<MyModel>(await events.next,
            [const MyModel(key: '1'), const MyModel(key: '2')], 1,
            removed: [], addedCount: 1);
      });

      test('add then update', () async {
        final events = StreamQueue(accessor.events);
        onChildAdded
            .add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '3')));
        expectListChangeRecord<MyModel>(
            await events.next, [const MyModel(key: '1', value: '3')], 0,
            removed: [], addedCount: 1);
        onChildChanged
            .add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '1')));
        expectListChangeRecord<MyModel>(
            await events.next, [const MyModel(key: '1', value: '1')], 0,
            removed: [const MyModel(key: '1', value: '3')], addedCount: 1);
      });

      test('add then error', () async {
        final events = StreamQueue(accessor.events);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expectListChangeRecord<MyModel>(
            await events.next, [const MyModel(key: '1')], 0,
            removed: [], addedCount: 1);
        onChildAdded.addError(const AccessDeniedError());
        try {
          await events.next;
          throw Exception('This should have failed!');
        } on DatabaseReadException catch (e) {
          expect(e.code, 13);
          expect(e.message, contains('Access denied'));
          expect(e.details, contains('READ'));
          expect(e.path, '/objects');
        }
        expect(() => events.next, throwsA(const TypeMatcher<StateError>()));
      });
    });

    group('getItem', () {
      test('value', () async {
        final item = accessor.getItem('test');
        onChildAdded.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'hello'),
        ));
        await allEventsDelivered();
        expect(item.loaded, true);
        expect(item.value, const MyModel(key: 'test', value: 'hello'));

        onChildChanged.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'world'),
        ));
        await allEventsDelivered();
        expect(item.loaded, true);
        expect(item.value, const MyModel(key: 'test', value: 'world'));

        onChildRemoved.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test'),
        ));
        await allEventsDelivered();
        expect(item.loaded, true);
        expect(item.value, null);

        onChildAdded.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'hello'),
        ));
        await allEventsDelivered();
        expect(item.loaded, true);
        expect(item.value, const MyModel(key: 'test', value: 'hello'));

        onChildAdded.addError(const AccessDeniedError());
        await allEventsDelivered();
        expect(item.loaded, true);
        expect(item.value, null);
      });

      test('updates', () async {
        final item = accessor.getItem('test');
        // Test stream at least a couple times to ensure that multiple
        // subscriptions work.
        for (var i = 0; i < 2; ++i) {
          // Can't use StreamQueue here because subscription to accessor.events
          // from item.updates is indirect and happens after the first onChild*
          // event is processed.
          expect(
              item.updates,
              emitsInOrder(<dynamic>[
                const MyModel(key: 'test', value: 'hello'),
                const MyModel(key: 'test', value: 'world'),
                null,
                const MyModel(key: 'test', value: 'hello'),
                emitsDone,
              ]));
        }
        onChildAdded.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'hello'),
        ));
        onChildChanged.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'world'),
        ));
        onChildRemoved.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test'),
        ));
        onChildAdded.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'hello'),
        ));
        await allEventsDelivered();
        accessor.close();
      });

      test('updates with error', () async {
        final item = accessor.getItem('test');
        // Can't use StreamQueue here because subscription to accessor.events
        // from item.updates is indirect and happens after the first onChild*
        // event is processed.
        expect(
            item.updates,
            emitsInOrder(<dynamic>[
              const MyModel(key: 'test', value: 'hello'),
              emitsError(const TypeMatcher<DatabaseReadException>()),
              emitsDone,
            ]));
        onChildAdded
          ..add(FakeEvent(
            snapshot: FakeSnapshot(key: 'test', value: 'hello'),
          ))
          ..addError(const AccessDeniedError());
      });
    });
  });

  group('FilteredListAccessor', () {
    test('updates filter successfully even before data arrives', () {
      FilteredListAccessor(MyListAccessor(dbReference)).filter =
          (model) => false;
    });
  });
}

@immutable
class AccessDeniedError implements DatabaseError {
  const AccessDeniedError();

  @override
  int get code => 13;

  @override
  String get message => 'Access denied';

  @override
  String get details => 'User does not have access to READ this node';
}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class FakeSnapshot implements DataSnapshot {
  @override
  final String key;

  @override
  final dynamic value;

  FakeSnapshot({this.key, this.value});
}

class FakeEvent implements Event {
  @override
  final String previousSiblingKey;

  @override
  final DataSnapshot snapshot;

  FakeEvent({this.previousSiblingKey, this.snapshot});
}

@immutable
class MyModel implements KeyedListItem {
  @override
  final String key;

  final dynamic value;

  const MyModel({this.key, this.value});

  @override
  bool operator ==(dynamic other) =>
      other is MyModel && key == other.key && value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  String toString() => '#<MyModel key: $key, value: $value>';
}

class MyListAccessor extends DataListAccessor<MyModel> {
  MyListAccessor(DatabaseReference reference) : super(reference);

  @override
  MyModel parseItem(String key, dynamic value) =>
      MyModel(key: key, value: value);
}

void expectListChangeRecord<T>(
    ListChangeRecord<T> actual, List<T> object, int index,
    {List<T> removed = const [], int addedCount = 0}) {
  expect(actual.object, BuiltList<T>.of(object));
  expect(actual.index, index);
  expect(actual.removed, BuiltList<T>.of(removed));
  expect(actual.addedCount, addedCount);
}

Future<void> allEventsDelivered() => Future<void>(() {});
