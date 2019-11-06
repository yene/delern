import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:meta/meta.dart';

const deckMimeType = 'application/flashcards-deck';

Future<void> logDeckCreate() =>
    FirebaseAnalytics().logEvent(name: 'deck_create');

Future<void> logDeckEditMenu(String deckId) =>
    FirebaseAnalytics().logEvent(name: 'deck_edit_menu', parameters: {
      'item_id': deckId,
    });

Future<void> logDeckEditSwipe(String deckId) =>
    FirebaseAnalytics().logEvent(name: 'deck_edit_swipe', parameters: {
      'item_id': deckId,
    });

Future<void> logDeckDeleteSwipe(String deckId) =>
    FirebaseAnalytics().logEvent(name: 'deck_delete_swipe', parameters: {
      'item_id': deckId,
    });

Future<void> logDeckDelete(String deckId) =>
    FirebaseAnalytics().logEvent(name: 'deck_delete', parameters: {
      'item_id': deckId,
    });

Future<void> logStartLearning(String deckId) =>
    FirebaseAnalytics().logEvent(name: 'deck_learning_start', parameters: {
      'item_id': deckId,
    });

Future<void> logShare({String deckId, String method}) =>
    FirebaseAnalytics().logShare(
      contentType: deckMimeType,
      itemId: deckId,
      method: method,
    );

Future<void> logUnshare({String deckId, String method}) =>
    FirebaseAnalytics().logShare(
      contentType: deckMimeType,
      itemId: '[unshared] $deckId',
      method: method,
    );

Future<void> logCardCreate(String deckId) =>
    FirebaseAnalytics().logEvent(name: 'card_create', parameters: {
      'item_id': deckId,
    });

Future<void> logCardResponse({@required String deckId, @required bool knows}) =>
    FirebaseAnalytics().logEvent(name: 'card_response', parameters: {
      'item_id': deckId,
      'knows': knows ? 1 : 0,
    });

Future<void> logPromoteAnonymous() =>
    FirebaseAnalytics().logEvent(name: 'promote_anonymous');

Future<void> logPromoteAnonymousFail() =>
    FirebaseAnalytics().logEvent(name: 'promote_anonymous_fail');
