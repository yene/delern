import 'dart:async';

import 'package:delern_flutter/models/base/delayed_initialization.dart';
import 'package:delern_flutter/models/base/transaction.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/filtered_sorted_observable_list.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class EditBloc extends ScreenBloc {
  final DeckModel deck;
  String _deckName;

  DelayedInitializationObservableList<CardModel> get list => _list;
  final FilteredSortedObservableList<CardModel> _list;

  set filter(Filter<CardModel> newValue) => _list.filter = newValue;
  Filter<CardModel> get filter => _list.filter;

  EditBloc({@required this.deck})
      : assert(deck != null),
        _list =
            // Analyzer bug: https://github.com/dart-lang/sdk/issues/35577.
            // ignore: unnecessary_parenthesis
            (FilteredSortedObservableList(CardModel.getList(deckKey: deck.key))
              ..comparator = (c1, c2) =>
                  c1.front.toLowerCase().compareTo(c2.front.toLowerCase())),
        _deckName = deck.name {
    _initListeners();
  }

  final _onDeckNameController = StreamController<String>();
  Sink<String> get onDeckName => _onDeckNameController.sink;

  void _initListeners() {
    _onDeckNameController.stream.listen((name) => _deckName = name);
  }

  @override
  @protected
  Future<bool> userClosesScreen() => _saveDeckSettings();

  Future<bool> _saveDeckSettings() async {
    deck.name = _deckName;
    /*..markdown = _markdown
      ..type = _deckType;*/
    try {
      await _save();
      return true;
    } catch (e, stackTrace) {
      unawaited(error_reporting.report('updateDeck', e, stackTrace));
      notifyErrorOccurred(e);
    }
    return false;
  }

  Future<void> _save() => (Transaction()..save(deck)).commit();

  @override
  void dispose() {
    _onDeckNameController.close();
    super.dispose();
  }
}
