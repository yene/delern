import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/card_preview/card_preview.dart';
import 'package:delern_flutter/views/cards_interval_learning/cards_interval_learning.dart';
import 'package:delern_flutter/views/cards_view_learning/cards_view_learning.dart';
import 'package:delern_flutter/views/deck_sharing/deck_sharing.dart';
import 'package:delern_flutter/views/edit_deck/edit_deck.dart';
import 'package:delern_flutter/views/support_dev/support_development.dart';
import 'package:flutter/material.dart';

import 'models/card_model.dart';
import 'models/deck_model.dart';

Future<void> openEditDeckScreen(BuildContext context, DeckModel deck) =>
    Navigator.push(
      context,
      MaterialPageRoute(
          settings: const RouteSettings(name: '/deck/edit'),
          builder: (context) => EditDeck(
                deck: deck,
              )),
    );

Future<void> openLearnCardIntervalScreen(
        BuildContext context, DeckModel deck) =>
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/decks/learn-interval'),
          // TODO(dotdoom): pass scheduled cards list to
          //  CardsLearning.
          builder: (context) => CardsIntervalLearning(deck: deck),
        ));

Future<void> openLearnCardViewScreen(BuildContext context, DeckModel deck) =>
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/decks/learn-view'),
          // TODO(dotdoom): pass scheduled cards list to
          //  CardsLearning.
          builder: (context) => CardsReviewLearning(deck: deck),
        ));

Future<void> openNewCardScreen(BuildContext context, DeckModel deck) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(name: '/cards/new'),
            builder: (context) => CardCreateUpdate(
                card: CardModel(deckKey: deck.key), deck: deck)));

Future<void> openEditCardScreen(
        BuildContext context, DeckModel deck, CardModel card) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            // 'name' is used by Firebase Analytics to log events.
            // TODO(dotdoom): consider better route names.
            settings: const RouteSettings(name: '/cards/edit'),
            builder: (context) => CardCreateUpdate(card: card, deck: deck)));

Future<void> openShareDeckScreen(BuildContext context, DeckModel deck) =>
    Navigator.push(
      context,
      MaterialPageRoute(
          settings: const RouteSettings(name: '/decks/share'),
          builder: (context) => DeckSharing(deck)),
    );

Future<void> openSupportDevelopmentScreen(BuildContext context) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(name: '/support'),
            builder: (context) => SupportDevelopment()));

Future<void> openPreviewCardScreen(
        BuildContext context, DeckModel deck, CardModel card) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(name: '/cards/preview'),
            builder: (context) => CardPreview(
                  card: card,
                  deck: deck,
                )));
