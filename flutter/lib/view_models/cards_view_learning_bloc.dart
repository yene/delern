import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class CardsViewLearningBloc extends ScreenBloc {
  final ListAccessor<CardModel> _cardList;

  CardsViewLearningBloc({@required User user, @required DeckModel deck})
      : _cardList = deck.cards,
        super(user) {
    _doGetCardsListController.add(_cardList.value);
    _onShuffleStreamController.stream.listen((_) {
      final shuffledCardList = _cardList.value.rebuild((cardListBuilder) {
        cardListBuilder.shuffle();
      });
      _doGetCardsListController.add(shuffledCardList);
    });
  }

  final _doGetCardsListController = BehaviorSubject<BuiltList<CardModel>>();
  Stream<BuiltList<CardModel>> get doGetCardsList =>
      _doGetCardsListController.stream;

  final _onShuffleStreamController = StreamController<void>();
  Sink<void> get onShuffleCards => _onShuffleStreamController.sink;

  @override
  void dispose() {
    _doGetCardsListController.close();
    _onShuffleStreamController.close();
    super.dispose();
  }
}
