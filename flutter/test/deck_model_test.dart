import 'package:built_collection/src/list.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/list_change_record.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:test/test.dart';

void main() {
  group('DeckModel', () {
    final deck = (DeckModelBuilder()..cards = FakeCardListAccessor()).build();

    test('tags', () {
      expect(deck.tags.value, {'#one', '#two', '#three'});
    });
  });
}

class FakeCardListAccessor implements DataListAccessor<CardModel> {
  @override
  BuiltList<CardModel> get value => BuiltList.of([
        (CardModelBuilder()
              ..front = '#one #two front'
              ..back = '#back back')
            .build(),
        (CardModelBuilder()
              ..front = '#three 45'
              ..back = '#not-a-tag')
            .build(),
      ]);

  @override
  bool get hasValue => true;

  @override
  Stream<ListChangeRecord<CardModel>> get events => null;

  @override
  DataListAccessorItem<CardModel> getItem(String key) => null;

  @override
  Stream<BuiltList<CardModel>> get updates => null;

  // The following methods are part of non-public interface, therefore unused.

  @override
  CardModel parseItem(String key, value) => null;

  @override
  CardModel updateItem(CardModel previous, String key, value) => previous;

  @override
  void close() {}

  @override
  void disposeItem(CardModel item) {}
}
