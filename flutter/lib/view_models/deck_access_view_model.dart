import 'dart:async';

import 'package:delern_flutter/models/base/delayed_initialization.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/view_models/base/filtered_sorted_observable_list.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class DeckAccessesViewModel {
  final DeckModel deck;
  final User user;

  DelayedInitializationObservableList<DeckAccessModel> get list => _list;
  final FilteredSortedObservableList<DeckAccessModel> _list;

  set filter(Filter<DeckAccessModel> newValue) => _list.filter = newValue;
  Filter<DeckAccessModel> get filter => _list.filter;

  DeckAccessesViewModel({@required this.user, @required this.deck})
      : assert(user != null),
        assert(deck != null),
        _list =
            // Analyzer bug: https://github.com/dart-lang/sdk/issues/35577.
            // ignore: unnecessary_parenthesis
            (FilteredSortedObservableList(
                DeckAccessModel.getList(deckKey: deck.key))
              ..comparator =
                  (c1, c2) => c1.access.index.compareTo(c2.access.index));

  Future<void> shareDeck(DeckAccessModel access) {
    assert(deck.key == access.deckKey);

    unawaited(logShare(access.deckKey));
    return user.shareDeck(
        deck: deck,
        access: access.access,
        shareWithUid: access.key,
        shareWithUserEmail: access.email);
  }

  Future<void> unshareDeck(String shareWithUid) {
    unawaited(logUnshare(deck.key));
    return user.unshareDeck(deck: deck, shareWithUid: shareWithUid);
  }
}
