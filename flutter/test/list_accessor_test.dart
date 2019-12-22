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
  MyListAccessor accessor;

  setUp(() {
    onChildAdded = StreamController<Event>();
    onChildChanged = StreamController<Event>();
    onChildRemoved = StreamController<Event>();

    final dbReference = MockDatabaseReference();
    when(dbReference.onChildAdded).thenAnswer((_) => onChildAdded.stream);
    when(dbReference.onChildRemoved).thenAnswer((_) => onChildRemoved.stream);
    when(dbReference.onChildChanged).thenAnswer((_) => onChildChanged.stream);
    when(dbReference.once()).thenAnswer((_) => Future.value(FakeSnapshot()));

    accessor = MyListAccessor(dbReference);
  });

  tearDown(() async {
    await onChildAdded.close();
    await onChildRemoved.close();
    await onChildChanged.close();
    accessor.close();
  });

  group('ListAccessor.updates', () {
    test('remove event', () async {
      expect(
          accessor.updates,
          emitsInOrder([
            BuiltList.of([const MyModel(key: '1')]),
            BuiltList.of(<MyModel>[]),
          ]));
      onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
      onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
    });

    test('add event', () {
      expect(
          accessor.updates,
          emitsInOrder([
            BuiltList.of([const MyModel(key: '1')]),
            BuiltList.of([const MyModel(key: '1'), const MyModel(key: '2')]),
          ]));
      onChildAdded
        ..add(FakeEvent(snapshot: FakeSnapshot(key: '1')))
        ..add(FakeEvent(snapshot: FakeSnapshot(key: '2')));
    });

    test('update event', () {
      expect(
          accessor.updates,
          emitsInOrder([
            BuiltList.of([const MyModel(key: '1', value: '3')]),
            BuiltList.of([const MyModel(key: '1', value: '1')]),
          ]));
      onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '3')));
      onChildChanged
          .add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '1')));
    });
  });

  group('ListAccessor.value', () {
    test('remove currentValue', () async {
      onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
      await allEventsDelivered();
      expect(accessor.value, BuiltList.of([const MyModel(key: '1')]));
      onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
      await allEventsDelivered();
      expect(accessor.value, BuiltList.of(<MyModel>[]));
    });

    test('add currentValue', () async {
      onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
      await allEventsDelivered();
      expect(accessor.value, BuiltList.of([const MyModel(key: '1')]));
      onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '2')));
      await allEventsDelivered();
      expect(accessor.value,
          BuiltList.of([const MyModel(key: '1'), const MyModel(key: '2')]));
    });

    test('update currentValue', () async {
      onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '3')));
      await allEventsDelivered();
      expect(
          accessor.value, BuiltList.of([const MyModel(key: '1', value: '3')]));
      onChildChanged
          .add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '1')));
      await allEventsDelivered();
      expect(
          accessor.value, BuiltList.of([const MyModel(key: '1', value: '1')]));
    });

    test('empty current value when initialized', () async {
      expect(accessor.value, const Iterable.empty());
    });
  });

  group('DataListAccessor.events', () {
    test('remove from event', () async {
      final events = StreamQueue(accessor.events);
      onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
      expectListChangeRecord<MyModel>(
          await events.next, [const MyModel(key: '1')], 0,
          removed: [], addedCount: 1);
      onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
      expectListChangeRecord<MyModel>(await events.next, [], 0,
          removed: [const MyModel(key: '1')]);
    });

    test('add to event', () async {
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

    test('update event', () async {
      final events = StreamQueue(accessor.events);
      onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '3')));
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

  group('DataListAccessorItem', () {
    test('DataListAccessorItem.value', () async {
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
