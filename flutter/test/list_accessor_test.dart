import 'dart:async';

import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

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

class MyObject implements KeyedListItem {
  @override
  final String key;

  final String value;

  MyObject(this.key, this.value);
}

class MyListAccessor extends ListAccessor<MyObject> {
  MyListAccessor(DatabaseReference reference) : super(reference);

  @override
  MyObject parseItem(String key, value) => MyObject(key, value);
}

void main() {
  final onChildAdded = StreamController<Event>(sync: true);
  final onChildRemoved = StreamController<Event>(sync: true);
  final onChildChanged = StreamController<Event>(sync: true);
  final dbReference = MockDatabaseReference();
  MyListAccessor accessor;

  setUpAll(() {
    when(dbReference.onChildAdded).thenAnswer((_) => onChildAdded.stream);
    when(dbReference.onChildRemoved).thenAnswer((_) => onChildRemoved.stream);
    when(dbReference.onChildChanged).thenAnswer((_) => onChildChanged.stream);
    accessor = MyListAccessor(dbReference);
  });

  tearDownAll(() async {
    await onChildAdded.close();
    await onChildRemoved.close();
    await onChildChanged.close();
  });

  test('remove event', () {
    onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
    expect(accessor.currentValue.first.key, '1');
    onChildRemoved.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
    expect(accessor.currentValue.length, 0);
  });

  test('add event', () {
    onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '1')));
    expect(accessor.currentValue[0].key, '1');
    final itemUpdates = accessor.getItemUpdates('2').listen((item) {
      expect(item.key, '2');
    });
    onChildAdded.add(FakeEvent(snapshot: FakeSnapshot(key: '2')));
    expect(accessor.currentValue.length, 2);
    itemUpdates.cancel();
  });

  test('update event', () {
    onChildChanged.add(FakeEvent(snapshot: FakeSnapshot(key: '1', value: '3')));
    expect(accessor.currentValue.length, 2);
    expect(accessor.currentValue[0].value, '3');
  });
}

class MockDatabaseReference extends Mock implements DatabaseReference {}
