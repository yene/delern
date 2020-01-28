import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/card_preview/card_preview.dart';
import 'package:delern_flutter/views/cards_interval_learning/cards_interval_learning.dart';
import 'package:delern_flutter/views/cards_view_learning/cards_view_learning.dart';
import 'package:delern_flutter/views/deck_sharing/deck_sharing.dart';
import 'package:delern_flutter/views/edit_deck/edit_deck.dart';
import 'package:delern_flutter/views/sign_in/sign_in.dart';
import 'package:delern_flutter/views/support_dev/support_development.dart';
import 'package:flutter/material.dart';

// How to specify RouteSettings name parameter:
// - each sequence of sub-components must be an existing route:
//   e.g. if your route name is /cards/new, then "/" and "/cards" and
//   "/cards/new" must all be existing named routes;
// - when nesting route into subcomponents, think of how the user will navigate
//   away when opening the route from an external link:
//   e.g. if the user clicks https://delern.org/cards/edit?deckId=1234abcd, they
//   will get to the "New card" page, and pressing "Back" will take them to
//   "Deck 1234abcd" page ("/cards" named route), and pressing "Back" again will
//   take them to list of decks page ("/" named route).

Future<void> openEditDeckScreen(
  BuildContext context, {
  @required String deckKey,
}) =>
    Navigator.pushNamed(
      context,
      EditDeck.routeName,
      arguments: EditDeck.buildArguments(deckKey: deckKey),
    );

Future<void> openLearnCardIntervalScreen(
        BuildContext context, DeckModel deck) =>
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: CardsIntervalLearning.routeName),
          builder: (context) => CardsIntervalLearning(deckKey: deck.key),
        ));

Future<void> openLearnCardViewScreen(BuildContext context, DeckModel deck) =>
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: CardsViewLearning.routeName),
          builder: (context) => CardsViewLearning(deck: deck),
        ));

Future<void> openNewCardScreen(
  BuildContext context, {
  @required String deckKey,
}) =>
    Navigator.pushNamed(
      context,
      CardCreateUpdate.routeNameNew,
      arguments: CardCreateUpdate.buildArguments(deckKey: deckKey),
    );

Future<void> openEditCardScreen(
  BuildContext context, {
  @required String deckKey,
  @required String cardKey,
}) =>
    Navigator.pushNamed(
      context,
      CardCreateUpdate.routeNameEdit,
      arguments: CardCreateUpdate.buildArguments(
        deckKey: deckKey,
        cardKey: cardKey,
      ),
    );

Future<void> openShareDeckScreen(BuildContext context, DeckModel deck) =>
    Navigator.push(
      context,
      MaterialPageRoute(
          settings: const RouteSettings(name: DeckSharing.routeName),
          builder: (context) => DeckSharing(deck)),
    );

Future<void> openSupportDevelopmentScreen(BuildContext context) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(name: SupportDevelopment.routeName),
            builder: (context) => SupportDevelopment()));

Future<void> openPreviewCardScreen(
  BuildContext context, {
  @required String deckKey,
  @required String cardKey,
}) =>
    Navigator.pushNamed(
      context,
      CardPreview.routeName,
      arguments: CardPreview.buildArguments(
        deckKey: deckKey,
        cardKey: cardKey,
      ),
    );

Future<void> openSignInScreen(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(
      settings: const RouteSettings(name: SignIn.routeName),
      builder: (_) => const SignIn(),
    ));
