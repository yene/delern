import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:observable/observable.dart';

abstract class ListAccessor<T> {
  bool get loaded;
  BuiltList<T> get currentValue;
  Stream<BuiltList<T>> get value;
  void close();
}

abstract class DataListAccessor<T extends KeyedListItem>
    implements ListAccessor<T> {
  final List<T> _currentValue = [];
  bool _loaded = false;
  final _value = StreamController<BuiltList<T>>.broadcast();
  final _events = StreamController<ListChangeRecord<T>>.broadcast();
  BuiltList<T> get currentValue =>
      _currentValue == null ? null : BuiltList.from(_currentValue);
  bool get loaded => _loaded;
  Stream<BuiltList<T>> get value => _value.stream;
  Stream<ListChangeRecord<T>> get events => _events.stream;

  StreamSubscription<Event> _onChildAdded, _onChildChanged, _onChildRemoved;

  DataListAccessor(DatabaseReference reference) {
    _onChildAdded = reference.onChildAdded.listen((data) {
      final newItem = parseItem(data.snapshot.key, data.snapshot.value);
      _currentValue.add(newItem);
      if (_loaded) {
        if (_value.hasListener) {
          _value.add(BuiltList.from(_currentValue));
        }
        if (_events.hasListener) {
          _events.add(ListChangeRecord<T>.add(
              _currentValue, _currentValue.length - 1, 1));
        }
      }
    });
    _onChildChanged = reference.onChildChanged.listen((data) {
      final newItem = parseItem(data.snapshot.key, data.snapshot.value);
      final index = _currentValue.indexWhere((item) => item.key == newItem.key);
      final replacedItem = _currentValue[index];
      disposeItem(replacedItem);
      _currentValue[index] = newItem;
      if (_loaded) {
        if (_value.hasListener) {
          _value.add(BuiltList.from(_currentValue));
        }
        if (_events.hasListener) {
          _events.add(ListChangeRecord<T>.replace(
              _currentValue, index, [replacedItem]));
        }
      }
    });
    _onChildRemoved = reference.onChildRemoved.listen((data) {
      final index =
          _currentValue.indexWhere((item) => item.key == data.snapshot.key);
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
    // Firstly onChildAdded listener are called. We don't send value, until
    // it is completely initialized. When it is done, send whole value to
    // listener
    reference.once().then((val) {
      _loaded = true;
      if (_value.hasListener) {
        _value.add(BuiltList.from(_currentValue));
      }
      if (_events.hasListener) {
        _events.add(
            ListChangeRecord<T>.add(_currentValue, 0, _currentValue.length));
      }
    });
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
    _currentValue?.forEach(disposeItem);
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

  FilteredListAccessor(this._base) : _currentValue = _base.currentValue {
    _baseValueSubscription = _base.value.listen((_) => _updateCurrentValue());
  }

  Filter<T> get filter => _filter;
  set filter(Filter<T> value) {
    _filter = value;
    _updateCurrentValue();
  }

  Stream<BuiltList<T>> get value => _value.stream;
  BuiltList<T> get currentValue => _currentValue;
  bool get loaded => _base.loaded;

  void close() {
    _value.close();
    _baseValueSubscription.cancel();
  }

  void _updateCurrentValue() {
    if (_filter == null) {
      _currentValue = _base.currentValue;
    } else {
      _currentValue = BuiltList<T>.of(_base.currentValue.where(_filter));
    }
    _value.add(_currentValue);
  }
}
