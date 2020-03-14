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

  test('ListAccessor (first set)', () async {
    // Since there's an unavoidable async gap between setUp and first test, we
    // extract tests for the very first accessor.updates and accessor.events
    // stream events (coming from dbReference.once) here.
    final accessor = MyListAccessor(dbReference);

    expect(
        accessor.updates,
        emitsInOrder([
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

  group('ListAccessor (subsequent changes)', () {
    MyListAccessor accessor;

    setUp(() {
      accessor = MyListAccessor(dbReference);
    });

    tearDown(() {
      accessor.close();
    });

    group('updates', () {
      test('remove', () async {
        final updates = StreamQueue(accessor.updates);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expect(await updates.next, BuiltList.of([const MyModel(key: '1')]));
        onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expect(await updates.next, BuiltList.of(<MyModel>[]));
      });

      test('add', () async {
        final updates = StreamQueue(accessor.updates);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expect(await updates.next, BuiltList.of([const MyModel(key: '1')]));
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '2')));
        expect(
          await updates.next,
          BuiltList.of([const MyModel(key: '1'), const MyModel(key: '2')]),
        );
      });

      test('update', () async {
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
    });

    group('value', () {
      test('remove', () async {
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        await allEventsDelivered();
        expect(accessor.value, BuiltList.of([const MyModel(key: '1')]));
        onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        await allEventsDelivered();
        expect(accessor.value, BuiltList.of(<MyModel>[]));
      });

      test('add', () async {
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        await allEventsDelivered();
        expect(accessor.value, BuiltList.of([const MyModel(key: '1')]));
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '2')));
        await allEventsDelivered();
        expect(accessor.value,
            BuiltList.of([const MyModel(key: '1'), const MyModel(key: '2')]));
      });

      test('update', () async {
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

      test('initial (empty)', () async {
        expect(accessor.value, const Iterable.empty());
      });
    });

    group('events', () {
      test('remove', () async {
        final events = StreamQueue(accessor.events);
        onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expectListChangeRecord<MyModel>(
            await events.next, [const MyModel(key: '1')], 0,
            removed: [], addedCount: 1);
        onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
        expectListChangeRecord<MyModel>(await events.next, [], 0,
            removed: [const MyModel(key: '1')]);
      });

      test('add', () async {
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

      test('update', () async {
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
    });

    group('getItem', () {
      test('value', () async {
        final item = accessor.getItem('test');
        expect(item.hasValue, false);
        expect(item.value, null);

        onChildAdded.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'hello'),
        ));
        await allEventsDelivered();
        expect(item.hasValue, true);
        expect(item.value, const MyModel(key: 'test', value: 'hello'));

        onChildChanged.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'world'),
        ));
        await allEventsDelivered();
        expect(item.hasValue, true);
        expect(item.value, const MyModel(key: 'test', value: 'world'));

        onChildRemoved.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test'),
        ));
        await allEventsDelivered();
        expect(item.hasValue, false);
        expect(item.value, null);

        onChildAdded.add(FakeEvent(
          snapshot: FakeSnapshot(key: 'test', value: 'hello'),
        ));
        await allEventsDelivered();
        expect(item.hasValue, true);
        expect(item.value, const MyModel(key: 'test', value: 'hello'));
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
              emitsInOrder([
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
    });
  });

  group('FilteredListAccessor', () {
    test('updates filter successfully even before data arrives', () {
      FilteredListAccessor(MyListAccessor(dbReference)).filter =
          (model) => false;
    });
  });
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

  final String value;

  const MyModel({this.key, this.value});

  @override
  bool operator ==(other) =>
      other is MyModel && key == other.key && value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  String toString() => '#<$runtimeType key: $key, value: $value>';
}

class MyListAccessor extends DataListAccessor<MyModel> {
  MyListAccessor(DatabaseReference reference) : super(reference);

  @override
  MyModel parseItem(String key, value) => MyModel(key: key, value: value);
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
