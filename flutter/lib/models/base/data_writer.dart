import 'package:delern_flutter/models/base/transaction.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/card_reply_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/fcm.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:meta/meta.dart';

@immutable
class DataWriter {
  final String uid;

  const DataWriter({@required this.uid}) : assert(uid != null);

  Future<DeckModel> createDeck({
    @required DeckModel deck,
    @required String email,
  }) async {
    await (Transaction()
          ..save(deck..access = AccessType.owner)
          ..save(DeckAccessModel(deckKey: deck.key)
            ..key = deck.uid
            ..access = AccessType.owner
            ..email = email))
        .commit();
    return deck;
  }

  Future<void> updateDeck({@required DeckModel deck}) =>
      (Transaction()..save(deck)).commit();

  Future<void> deleteDeck({@required DeckModel deck}) async {
    final t = Transaction()..delete(deck);
    final card = CardModel(deckKey: deck.key);
    if (deck.access == AccessType.owner) {
      final accessList = DeckAccessModel.getList(deckKey: deck.key);
      await accessList.fetchFullValue();
      accessList
          .forEach((a) => t.delete(DeckModel(uid: a.key)..key = deck.key));
      t..deleteAll(DeckAccessModel(deckKey: deck.key))..deleteAll(card);
      // TODO(dotdoom): delete other users' ScheduledCard and Views?
    }
    t
      ..deleteAll(ScheduledCardModel(deckKey: deck.key, uid: deck.uid))
      ..deleteAll((CardReplyModelBuilder()
            ..uid = deck.uid
            ..deckKey = deck.key
            ..cardKey = null)
          .build());
    return t.commit();
  }

  Future<void> createOrUpdateCard({
    @required CardModel card,
    bool addReversed = false,
  }) {
    final t = Transaction()..save(card);
    final sCard = ScheduledCardModel(deckKey: card.deckKey, uid: uid)
      ..key = card.key;
    t.save(sCard);

    if (addReversed) {
      final reverse = CardModel.copyFrom(card)
        ..key = null
        ..front = card.back
        ..back = card.front;
      t.save(reverse);
      final reverseScCard =
          ScheduledCardModel(deckKey: reverse.deckKey, uid: uid)
            ..key = reverse.key;
      t.save(reverseScCard);
    }
    return t.commit();
  }

  Future<void> deleteCard({@required CardModel card}) => (Transaction()
        ..delete(card)
        ..delete(ScheduledCardModel(deckKey: card.deckKey, uid: uid)
          ..key = card.key))
      .commit();

  Future<void> learnCard({
    @required CardModel card,
    @required ScheduledCardModel scheduledCard,
    @required bool knows,
    @required bool learnBeyondHorizon,
  }) {
    final cv = scheduledCard.answer(
        knows: knows, learnBeyondHorizon: learnBeyondHorizon);
    return (Transaction()..save(scheduledCard)..save(cv)).commit();
  }

  Future<void> unshareDeck({
    @required DeckModel deck,
    @required String shareWithUid,
  }) =>
      (Transaction()
            ..delete(DeckAccessModel(
              deckKey: deck.key,
            )..key = shareWithUid))
          .commit();

  Future<void> shareDeck({
    @required DeckModel deck,
    @required String shareWithUid,
    @required AccessType access,
    String sharedDeckName,
    String shareWithUserEmail,
  }) async {
    final accessModel = DeckAccessModel(deckKey: deck.key)
      ..key = shareWithUid
      ..access = access
      ..email = shareWithUserEmail;

    final tr = Transaction()..save(accessModel);
    if ((await DeckAccessModel.get(deckKey: deck.key, key: shareWithUid).first)
            .key ==
        null) {
      // If there's no DeckAccess, assume the deck hasn't been shared yet.
      tr.save(DeckModel.copyFrom(deck)
        ..uid = shareWithUid
        ..accepted = false
        ..name = sharedDeckName ?? deck.name
        ..access = access);
    }

    return tr.commit();
  }

  Future<void> addFCM({@required FCM fcm}) =>
      (Transaction()..save(fcm)).commit();
}
