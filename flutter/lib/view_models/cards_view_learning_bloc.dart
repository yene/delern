import 'package:built_collection/built_collection.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:flutter/cupertino.dart';

class CardsViewLearningBloc extends ScreenBloc {
  final ListAccessor<CardModel> _cardList;

  CardsViewLearningBloc({@required User user, @required DeckModel deck})
      : _cardList = deck.cards,
        super(user);

  StreamWithValue<BuiltList<CardModel>> get doGetCardList => _cardList;
}
