import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:flutter/cupertino.dart';

class CardsViewLearningBloc extends ScreenBloc {
  StreamWithLatestValue<BuiltList<CardModel>> _doSetCardsList;
  StreamWithValue<BuiltList<CardModel>> get doSetCardsList => _doSetCardsList;

  CardsViewLearningBloc({@required User user, @required DeckModel deck})
      : super(user) {
    _doSetCardsList = StreamWithLatestValue(
        _onShuffleStreamController.stream.mapPerEvent(
          (_) => deck.cards.value?.rebuild(
            (cardListBuilder) => cardListBuilder.shuffle(),
          ),
        ),
        initialValue: deck.cards.value);
  }

  final _onShuffleStreamController = StreamController<void>.broadcast();
  Sink<void> get onShuffleCards => _onShuffleStreamController.sink;

  @override
  void dispose() {
    _onShuffleStreamController.close();
    super.dispose();
  }
}
