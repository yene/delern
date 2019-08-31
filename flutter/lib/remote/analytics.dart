import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';

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

Future<void> logShare(String deckId) => FirebaseAnalytics()
    .logShare(contentType: 'application/flashcards-deck', itemId: deckId);

Future<void> logUnshare(String deckId) => FirebaseAnalytics().logShare(
    contentType: 'application/flashcards-deck', itemId: '[unshared] $deckId');

Future<void> logCardCreate(String deckId) =>
    FirebaseAnalytics().logEvent(name: 'card_create', parameters: {
      'item_id': deckId,
    });

Future<void> logPromoteAnonymous() =>
    FirebaseAnalytics().logEvent(name: 'promote_anonymous');

Future<void> logPromoteAnonymousFail() =>
    FirebaseAnalytics().logEvent(name: 'promote_anonymous_fail');
