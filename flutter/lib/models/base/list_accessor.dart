import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_change_record.dart';
import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

// https://github.com/dart-lang/linter/issues/1826
// ignore: one_member_abstracts
abstract class ListAccessor<T> implements StreamWithValue<BuiltList<T>> {
  void close();
}

abstract class DataListAccessor<T extends KeyedListItem>
    implements ListAccessor<T> {
  final List<T> _currentValue = [];
  bool _loaded = false;
  final _value = StreamController<BuiltList<T>>.broadcast();
  final _events = StreamController<ListChangeRecord<T>>.broadcast();
  @override
  BuiltList<T> get value =>
      _currentValue == null ? null : BuiltList.from(_currentValue);
  @override
  bool get hasValue => _loaded;
  @override
  Stream<BuiltList<T>> get updates => _value.stream;
  Stream<ListChangeRecord<T>> get events => _events.stream;

  StreamSubscription<Event> _onChildAdded, _onChildChanged, _onChildRemoved;

  DataListAccessor(DatabaseReference reference) {
    _onChildAdded = reference.onChildAdded.listen(_childAddedOrChanged);
    _onChildChanged = reference.onChildChanged.listen(_childAddedOrChanged);
    _onChildRemoved = reference.onChildRemoved.listen((data) {
      final index = _currentValue.indexOfKey(data.snapshot.key);
      final deletedItem = _currentValue[index];
      _currentValue.removeAt(index);
      disposeItem(deletedItem);
      if (_loaded) {
        if (_value.hasListener) {
          _value.add(BuiltList.from(_currentValue));
        }
        if (_events.hasListener) {
          _events.add(
              ListChangeRecord<T>.remove(_currentValue, index, [deletedItem]));
        }
      }
    });
    // onChildAdded listener will be called first, but we don't send updates
    // until we get the full list value.
    reference.once().then((val) {
      _loaded = true;
      // TODO(dotdoom): replace/update current value with val.

      if (_value.hasListener) {
        _value.add(BuiltList.from(_currentValue));
      }
      if (_events.hasListener) {
        _events.add(
            ListChangeRecord<T>.add(_currentValue, 0, _currentValue.length));
      }
    });
  }

  void _childAddedOrChanged(Event data) {
    final existingIndex = _currentValue.indexOfKey(data.snapshot.key);
    if (existingIndex >= 0) {
      final replacedItem = _currentValue[existingIndex];
      _currentValue[existingIndex] =
          updateItem(replacedItem, data.snapshot.key, data.snapshot.value);
      if (_loaded && _events.hasListener) {
        _events.add(ListChangeRecord<T>.replace(
            _currentValue, existingIndex, [replacedItem]));
      }
    } else {
      _currentValue.add(parseItem(data.snapshot.key, data.snapshot.value));
      if (_loaded && _events.hasListener) {
        _events.add(ListChangeRecord<T>.add(
            _currentValue, _currentValue.length - 1, 1));
      }
    }
    if (_loaded && _value.hasListener) {
      _value.add(BuiltList.from(_currentValue));
    }
  }

  Stream<T> getItemUpdates(String key) async* {
    await for (final listChangedRecord in events) {
      final addedItem = listChangedRecord.added
          .firstWhere((item) => item.key == key, orElse: () => null);
      final itemWasRemoved =
          listChangedRecord.removed.any((item) => item.key == key);
      if (addedItem != null || itemWasRemoved) {
        yield addedItem;
      }
    }
  }

  @protected
  T parseItem(String key, value);

  @protected
  T updateItem(T previous, String key, value) => parseItem(key, value);

  @protected
  void disposeItem(T item) {}

  @override
  void close() {
    _currentValue
      ..forEach(disposeItem)
      ..clear();
    _onChildAdded?.cancel();
    _onChildChanged?.cancel();
    _onChildRemoved?.cancel();
    _events?.close();
  }
}

typedef Filter<T> = bool Function(T item);

/// We use Decorator pattern because _base is an abstract class.
class FilteredListAccessor<T extends KeyedListItem> implements ListAccessor<T> {
  final ListAccessor<T> _base;
  Filter<T> _filter;
  BuiltList<T> _currentValue;
  StreamSubscription<BuiltList<T>> _baseValueSubscription;
  final _value = StreamController<BuiltList<T>>.broadcast();

  FilteredListAccessor(this._base) : _currentValue = _base.value {
    _baseValueSubscription = _base.updates.listen((_) => _updateCurrentValue());
  }

  Filter<T> get filter => _filter;
  set filter(Filter<T> value) {
    _filter = value;
    _updateCurrentValue();
  }

  @override
  Stream<BuiltList<T>> get updates => _value.stream;
  @override
  BuiltList<T> get value => _currentValue;
  @override
  bool get hasValue => _base.hasValue;

  @override
  void close() {
    _value.close();
    _baseValueSubscription.cancel();
  }

  void _updateCurrentValue() {
    if (_filter == null) {
      _currentValue = _base.value;
    } else {
      _currentValue = BuiltList<T>.of(_base.value.where(_filter));
    }
    _value.add(_currentValue);
  }
}
