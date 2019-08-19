import 'dart:async';

import 'package:delern_flutter/models/base/database_observable_list.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:flutter/cupertino.dart';

class CardsReviewLearningBloc extends ScreenBloc {
  final DatabaseObservableList<CardModel> _cardList;

  CardsReviewLearningBloc({@required deck})
      : _cardList = CardModel.getList(deckKey: deck.key) {
    _initListeners();
  }

  final _doGetCardListController = StreamController<List<CardModel>>();
  Stream<List<CardModel>> get doGetCardList => _doGetCardListController.stream;

  Future<void> _initListeners() async {
    await _cardList.fetchFullValue();
    _doGetCardListController.add(_cardList);
  }

  @override
  void dispose() {
    _doGetCardListController.close();
    super.dispose();
  }
}
