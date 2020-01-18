import 'dart:async';

import 'package:delern_flutter/models/base/stream_muxer.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:meta/meta.dart';

enum LearningUpdateType {
  deckUpdate,
  scheduledCardUpdate,
}

class LearningViewModel {
  final User user;

  ScheduledCardModel get scheduledCard => _scheduledCard;
  ScheduledCardModel _scheduledCard;

  Stream<CardModel> get card => _card;
  Stream<CardModel> _card;

  CardModel get initialCard => _initialCard;
  CardModel _initialCard;

  DeckModel get deck => _deck;
  DeckModel _deck;

  LearningViewModel({@required this.user, @required DeckModel deck})
      : assert(user != null),
        assert(deck != null),
        _deck = deck;

  Stream<LearningUpdateType> get updates {
    logStartLearning(deck.key);
    return StreamMuxer({
      LearningUpdateType.deckUpdate:
          user.decks.getItem(deck.key).updates.map((d) => _deck = d),
      LearningUpdateType.scheduledCardUpdate:
          ScheduledCardModel.next(user, deck).map((casc) {
        _initialCard = casc.initialCard;
        _card = casc.card;
        _scheduledCard = casc.scheduledCard;
      }),
      // We deliberately do not subscribe to Card updates (i.e. we only watch
      // ScheduledCard). If the card that the user is looking at right now is
      // updated live, it can result in bad user experience.
    }).map((muxerEvent) => muxerEvent.key);
  }

  Future<void> answer(
      {@required bool knows, @required bool learnBeyondHorizon}) {
    logCardResponse(deckId: deck.key, knows: knows);
    return user.learnCard(
        unansweredScheduledCard: _scheduledCard,
        knows: knows,
        learnBeyondHorizon: learnBeyondHorizon);
  }

  Future<void> deleteCard() => user.deleteCard(card: initialCard);
}
