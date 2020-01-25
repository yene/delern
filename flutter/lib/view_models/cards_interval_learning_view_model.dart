import 'dart:async';

import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:meta/meta.dart';

class CardsIntervalLearningViewModel {
  final User user;
  final StreamWithValue<DeckModel> deck;

  ScheduledCardModel _scheduledCard;
  bool _learningStarted = false;

  CardsIntervalLearningViewModel({
    @required this.user,
    @required String deckKey,
  })  : assert(user != null),
        assert(deckKey != null),
        deck = user.decks.getItem(deckKey);

  Stream<ScheduledCardModel> get updates =>
      ScheduledCardModel.next(user, deck.value)
          .map((casc) => _scheduledCard = casc.scheduledCard);

  Future<void> answer({
    @required bool knows,
  }) {
    if (!_learningStarted) {
      logStartLearning(deck.value.key);
      _learningStarted = true;
    }
    logCardResponse(deckId: deck.value.key, knows: knows);
    return user.learnCard(
      unansweredScheduledCard: _scheduledCard,
      knows: knows,
    );
  }
}
