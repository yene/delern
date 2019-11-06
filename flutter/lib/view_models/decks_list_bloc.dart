import 'dart:async';

import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class ScheduledCardsUpdate {
  String deckKey;
  int numberOfCardsToLearn;
}

class DecksListBloc {
  final User user;

  ListAccessor<DeckModel> get decksList => _filteredDecksList;
  FilteredListAccessor<DeckModel> _filteredDecksList;

  final StreamController<ScheduledCardsUpdate> _doScheduledCardsUpdates =
      StreamController<ScheduledCardsUpdate>.broadcast();
  Stream<ScheduledCardsUpdate> get doScheduledCardsUpdates =>
      _doScheduledCardsUpdates.stream;

  set decksListFilter(Filter<DeckModel> newValue) =>
      _filteredDecksList.filter = newValue;
  Filter<DeckModel> get decksListFilter => _filteredDecksList.filter;

  DecksListBloc({@required this.user}) : assert(user != null) {
    _filteredDecksList = FilteredListAccessor<DeckModel>(user.decks);
  }

  Future<DeckModel> createDeck(DeckModel deck) {
    logDeckCreate();
    return user.createDeck(deckTemplate: deck);
  }

  StreamWithValue<bool> get isOnline => user.isOnline;

  /// Close all streams and release associated timer resources.
  // TODO(dotdoom): consider self-disposing map elements for onCancel of stream.
  void dispose() {
    _filteredDecksList.close();
    _doScheduledCardsUpdates.close();
  }

  Future<void> deleteDeck(DeckModel deck) => user.deleteDeck(deck: deck);
}
