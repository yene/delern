import 'dart:async';

import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:meta/meta.dart';

class CardsIntervalLearningViewModel {
  final User user;
  final StreamWithValue<DeckModel> deck;

  CardsIntervalLearningViewModel({
    @required this.user,
    @required String deckKey,
  })  : assert(user != null),
        assert(deckKey != null),
        deck = user.decks.getItem(deckKey);

  Stream<ScheduledCardModel> get updates =>
      ScheduledCardModel.next(user, deck.value)
          .map((casc) => casc.scheduledCard);
}
