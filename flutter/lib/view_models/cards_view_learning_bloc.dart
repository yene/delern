import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:flutter/cupertino.dart';

class CardsViewLearningBloc extends ScreenBloc {
  final StreamWithValue<DeckModel> deck;

  StreamWithLatestValue<BuiltList<CardModel>> _doSetCardsList;
  StreamWithValue<BuiltList<CardModel>> get doSetCardsList => _doSetCardsList;

  CardsViewLearningBloc({
    @required User user,
    @required this.deck,
    @required BuiltSet<String> tags,
  }) : super(user) {
    _doSetCardsList = StreamWithLatestValue(
      _onShuffleStreamController.stream.mapPerEvent(
        (_) => _cardsFilteredByTags(tags).rebuild(
          (cardListBuilder) => cardListBuilder.shuffle(),
        ),
      ),
      initialValue: _cardsFilteredByTags(tags),
    );
  }

  final _onShuffleStreamController = StreamController<void>.broadcast();
  Sink<void> get onShuffleCards => _onShuffleStreamController.sink;

  BuiltList<CardModel> _cardsFilteredByTags(BuiltSet<String> tags) {
    final cards = deck.value.cards.value;

    if (tags.isEmpty) {
      return cards;
    }

    return BuiltList<CardModel>.of(
        cards.where((card) => card.tags.intersection(tags).isNotEmpty));
  }

  @override
  void dispose() {
    _onShuffleStreamController.close();
    super.dispose();
  }
}
