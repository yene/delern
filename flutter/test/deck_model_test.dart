import 'dart:async';

import 'package:built_collection/src/list.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/list_change_record.dart';
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:test/test.dart';

void main() {
  group('DeckModel', () {
    DeckModel deck;
    Sink<ListChangeRecord<CardModel>> deckCards;

    setUp(() {
      deck = (DeckModelBuilder()
            ..cards = _DataListAccessor((deckCards =
                    StreamController<ListChangeRecord<CardModel>>())
                .stream))
          .build();
    });

    tearDown(() {
      deckCards.close();
    });

    test('tags', () async {
      final cards = [
        (CardModelBuilder()
              ..front = '#one #two front'
              ..back = '#back back')
            .build(),
        (CardModelBuilder()
              ..front = '#three 45'
              ..back = '#not-a-tag')
            .build(),
      ];
      deckCards.add(ListChangeRecord.add(cards, 0, cards.length));
      await null;
      expect(deck.tags.value, {'#one', '#two', '#three'});
    });
  });
}

class _DataListAccessor<T extends KeyedListItem>
    with _ListAccessorItemStubsMixin<T>
    implements DataListAccessor<T> {
  final _value = StreamController<BuiltList<T>>.broadcast();
  final _events = StreamController<ListChangeRecord<T>>.broadcast();
  final _currentValue = <T>[];
  var _hasValue = false;

  StreamSubscription<ListChangeRecord<T>> _sourceSubscription;

  _DataListAccessor(Stream<ListChangeRecord<T>> source) {
    _sourceSubscription = source.listen((change) {
      _hasValue = true;
      _currentValue
        ..removeRange(change.index, change.removed.length)
        ..insertAll(change.index, change.added);
      _value.add(value);
      _events.add(change);
    });
  }

  @override
  Stream<ListChangeRecord<T>> get events => _events.stream;

  @override
  StreamWithValue<T> getItem(String key) => DataListAccessorItem(this, key);

  @override
  bool get hasValue => _hasValue;

  @override
  Stream<BuiltList<T>> get updates => _value.stream;

  @override
  BuiltList<T> get value => BuiltList<T>.of(_currentValue);

  @override
  void close() {
    _sourceSubscription.cancel();
    _currentValue
      ..forEach(disposeItem)
      ..clear();
    _events.close();
    _value.close();
  }
}

mixin _ListAccessorItemStubsMixin<T extends KeyedListItem>
    implements DataListAccessor<T> {
  @override
  T parseItem(String key, dynamic value) => null;

  @override
  T updateItem(T previous, String key, dynamic value) => parseItem(key, value);

  @override
  void disposeItem(T item) {}
}
