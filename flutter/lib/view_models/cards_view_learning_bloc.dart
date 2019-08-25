import 'dart:async';

import 'package:delern_flutter/models/base/database_observable_list.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:flutter/cupertino.dart';

class CardsViewLearningBloc extends ScreenBloc {
  final DatabaseObservableList<CardModel> _cardList;

  CardsViewLearningBloc({@required deck})
      : _cardList = CardModel.getList(deckKey: deck.key);

  Stream<List<CardModel>> get doGetCardList =>
      _cardList.listChanges.map((_) => _cardList);

  Stream<int> get doGetNumberOfCards =>
      _cardList.listChanges.map((_) => _cardList.length);
}
