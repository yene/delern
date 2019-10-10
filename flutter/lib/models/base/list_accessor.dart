import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:observable/observable.dart';

abstract class ListAccessor<T extends KeyedListItem> {
  List<T> _currentValue;
  final _value = StreamController<BuiltList<T>>.broadcast();
  final _events = StreamController<ListChangeRecord<T>>.broadcast();

  StreamSubscription<Event> _onChildAdded;
  StreamSubscription<Event> _onChildChanged;
  StreamSubscription<Event> _onChildRemoved;

  ListAccessor(DatabaseReference reference) {
    _onChildAdded = reference.onChildAdded.listen((data) {
      final newItem = parseItem(data.snapshot.key, data.snapshot.value);
      _currentValue ??= [];
      _currentValue.add(newItem);
      if (_value.hasListener) {
        _value.add(BuiltList.from(_currentValue));
      }
      if (_events.hasListener) {
        _events.add(
            ListChangeRecord.add(_currentValue, _currentValue.length - 1, 1));
      }
    });
    _onChildChanged = reference.onChildChanged.listen((data) {
      final newItem = parseItem(data.snapshot.key, data.snapshot.value);
      final index = _currentValue.indexWhere((item) => item.key == newItem.key);
      final replacedItem = _currentValue[index];
      disposeItem(replacedItem);
      _currentValue[index] = newItem;
      if (_value.hasListener) {
        _value.add(BuiltList.from(_currentValue));
      }
      if (_events.hasListener) {
        _events.add(
            ListChangeRecord.replace(_currentValue, index, [replacedItem]));
      }
    });
    _onChildRemoved = reference.onChildRemoved.listen((data) {
      final index =
          _currentValue.indexWhere((item) => item.key == data.snapshot.key);
      final deletedItem = _currentValue[index];
      _currentValue.removeAt(index);
      disposeItem(deletedItem);
      if (_value.hasListener) {
        _value.add(BuiltList.from(_currentValue));
      }
      if (_events.hasListener) {
        _events
            .add(ListChangeRecord.remove(_currentValue, index, [deletedItem]));
      }
    });
  }

  BuiltList<T> get currentValue => BuiltList.from(_currentValue);
  Stream<BuiltList<T>> get value => _value.stream;

  Stream<ListChangeRecord<T>> get events => _events.stream;

  Stream<T> getItemUpdates(String key) async* {
    await for (final listChangedRecord in events) {
      // New items were added
      if (listChangedRecord.addedCount > 0 &&
          listChangedRecord.removed.isEmpty) {
        for (var i = listChangedRecord.index;
            i < (listChangedRecord.index + listChangedRecord.addedCount);
            i++) {
          if (listChangedRecord.object[i].key == key) {
            yield listChangedRecord.object[i];
            break;
          }
        }
      }
      // Items were removed
      if (listChangedRecord.addedCount == 0 &&
          listChangedRecord.removed.isNotEmpty) {
        for (var i = 0; i < listChangedRecord.removed.length; i++) {
          if (listChangedRecord.removed[i].key == key) {
            yield null;
            break;
          }
        }
      }
      // Items were changed
      if (listChangedRecord.addedCount > 0 &&
          listChangedRecord.removed.isNotEmpty) {
        for (var i = 0; i < listChangedRecord.removed.length; i++) {
          if (listChangedRecord.removed[i].key == key) {
            // Find new value of item
            for (var j = listChangedRecord.index;
                j < listChangedRecord.index + listChangedRecord.addedCount;
                j++) {
              if (listChangedRecord.object[j].key == key) {
                yield listChangedRecord.object[j];
                break;
              }
            }
            break;
          }
        }
      }
    }
  }

  @protected
  T parseItem(String key, value);

  @protected
  T updateItem(T previous, String key, value) => parseItem(key, value);

  @protected
  void disposeItem(T item) {}

  void close() {
    _onChildAdded.cancel();
    _onChildChanged.cancel();
    _onChildRemoved.cancel();
    _events.close();
  }
}
