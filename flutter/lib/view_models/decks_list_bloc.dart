import 'dart:async';

import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class NumberOfCardsDue {
  int get value => _value;
  int _value = 0;

  Stream<int> get stream => _controller.stream;
  final _controller = StreamController<int>.broadcast();

  Timer _refreshTimer;

  NumberOfCardsDue._();

  void _addValue(int newValue) {
    _value = newValue;
    _controller.add(newValue);
  }

  void _dispose() {
    _controller.close();
    _refreshTimer?.cancel();
  }
}

class DecksListBloc {
  final User user;

  /*DelayedInitializationObservableList<DeckModel> get decksList => _decksList;
  final FilteredSortedObservableList<DeckModel> _decksList;*/
  ListAccessor<DeckModel> get decksList => _filteredDecksList;
  FilteredListAccessor<DeckModel> _filteredDecksList;

  // TODO(ksheremet): Implement filter
  set decksListFilter(Filter<DeckModel> newValue) =>
      _filteredDecksList.filter = newValue;
  //_decksList.filter = newValue;
  Filter<DeckModel> get decksListFilter =>
      _filteredDecksList.filter; //_decksList.filter;

  DecksListBloc({@required this.user})
      : assert(user !=
            null) // Analyzer bug: https://github.com/dart-lang/sdk/issues/35577.
  // ignore: unnecessary_parenthesis
  /*(FilteredSortedObservableList(user.decks.currentValue)
              ..comparator = (c1, c2) => c1.key.compareTo(c2.key))*/
  {
    _filteredDecksList = FilteredListAccessor<DeckModel>(user.decks);
    // Delay initial data load. In case we have a significant amount of
    // ScheduledCards, loading them slows down decks list, because of the
    // MethodChannel bottleneck.
    Future.delayed(const Duration(milliseconds: 100), _loadScheduledCards);
  }

  Future<DeckModel> createDeck(DeckModel deck) {
    logDeckCreate();
    return user.createDeck(deckTemplate: deck);
  }

  void _loadScheduledCards() {
    final list = ScheduledCardModel.listsForUser(user.uid);
    list.listChanges.listen((changes) {
      changes.forEach((change) {
        // TODO(dotdoom): detect changes rather than plain add/remove!
        change.removed.forEach((scheduledCardsList) {
          if (_numberOfCardsDue.containsKey(scheduledCardsList.key)) {
            // Do not close the stream. itemRemoved occurs when we do not have
            // any cards left in a deck; once the user adds another card, we
            // will have to notify our subscribers, which will be gone if we
            // call close().
            // TODO(dotdoom): consider using _processor to find out when a deck
            //                is removed and resources can be released.
            _numberOfCardsDue[scheduledCardsList.key]
              .._refreshTimer?.cancel()
              .._addValue(0);
          }
        });

        for (var listIndex = change.index;
            listIndex < change.index + change.addedCount;
            ++listIndex) {
          _scheduledCardsChanged(
              list[listIndex].key, list[listIndex].scheduledCards);
        }
      });
    });
  }

  StreamWithValue<bool> get isOnline => user.isOnline;

  /// A delay between next scheduled card and our timer trigger, to avoid time
  /// computation uncertainties, and also avoid timer restart churn if multiple
  /// cards come with a small interval between them.
  static const _timerDelay = Duration(seconds: 30);

  void _scheduledCardsChanged(
      String deckKey, Iterable<ScheduledCardModel> value) {
    final now = DateTime.now();
    final notYetDue = value.where((sc) => sc.repeatAt.isAfter(now));

    final cardsDue = numberOfCardsDue(deckKey)
      .._addValue(value.length - notYetDue.length);

    cardsDue._refreshTimer?.cancel();
    if (notYetDue.isNotEmpty) {
      // Find the closest (minimum) repeatAt.
      final nextRepeatAt = notYetDue
          .reduce((m1, m2) => m1.repeatAt.isBefore(m2.repeatAt) ? m1 : m2)
          .repeatAt;
      final refreshTimerInterval = nextRepeatAt.difference(now) + _timerDelay;
      debugPrint(
          'Setting deck $deckKey refresh timer for $refreshTimerInterval');
      // Set timer to re-run this method when next repeatAt is due.
      cardsDue._refreshTimer = Timer(
          refreshTimerInterval, () => _scheduledCardsChanged(deckKey, value));
    }
  }

  /// Current value and a stream of values for the number of ScheduledCards due
  /// for learning. This method never returns null.
  NumberOfCardsDue numberOfCardsDue(String deckKey) =>
      // Put StreamController in place even if we don't have data for this deck
      // yet. Later, when we get information about this deck, we will push new
      // data directly to a subscriber.
      // Do not remove this controller from the list in
      // StreamController.onCancel, because there may be more references to it,
      // which can re-subscribe in future.
      _numberOfCardsDue.putIfAbsent(deckKey, () => NumberOfCardsDue._());
  final _numberOfCardsDue = <String, NumberOfCardsDue>{};

  /// Close all streams and release associated timer resources.
  // TODO(dotdoom): consider self-disposing map elements for onCancel of stream.
  void dispose() {
    _numberOfCardsDue.values.forEach((c) => c._dispose());
    _filteredDecksList.close();
  }

  Future<void> deleteDeck(DeckModel deck) => user.deleteDeck(deck: deck);
}
