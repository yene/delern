import 'dart:async';

import 'package:delern_flutter/models/base/delayed_initialization.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/filtered_sorted_observable_list.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class EditDeckBloc extends ScreenBloc {
  DeckModel _deck;

  DelayedInitializationObservableList<CardModel> get list => _list;
  final FilteredSortedObservableList<CardModel> _list;

  set filter(Filter<CardModel> newValue) => _list.filter = newValue;
  Filter<CardModel> get filter => _list.filter;

  EditDeckBloc({@required User user, @required DeckModel deck})
      : assert(deck != null),
        _deck = deck,
        _list =
            // Analyzer bug: https://github.com/dart-lang/sdk/issues/35577.
            // ignore: unnecessary_parenthesis
            (FilteredSortedObservableList(CardModel.getList(deckKey: deck.key))
              ..comparator = (c1, c2) =>
                  c1.front.toLowerCase().compareTo(c2.front.toLowerCase())),
        super(user) {
    _doDeckChangedController.add(_deck);
    _initListeners();
  }

  final _onDeckNameController = StreamController<String>();
  Sink<String> get onDeckName => _onDeckNameController.sink;

  final _onDeleteDeckController = StreamController<void>();
  Sink<void> get onDeleteDeck => _onDeleteDeckController.sink;

  final _onDeleteDeckIntention = StreamController<void>();
  Sink<void> get onDeleteDeckIntention => _onDeleteDeckIntention.sink;

  // This stream is used in deck settings (popup menu). To open deck settings
  // more than one time, we need a broadcast.
  final _doShowConfirmationDialogController =
      StreamController<String>.broadcast();
  Stream<String> get doShowDeleteConfirmationDialog =>
      _doShowConfirmationDialogController.stream;

  final _doDeckChangedController = StreamController<DeckModel>();
  Stream<DeckModel> get doDeckChanged => _doDeckChangedController.stream;

  final _onDeckTypeController = StreamController<DeckType>();
  Sink<DeckType> get onDeckType => _onDeckTypeController.sink;

  final _onMarkdownController = StreamController<bool>();
  Sink<bool> get onMarkdown => _onMarkdownController.sink;

  void _initListeners() {
    _onDeckNameController.stream.listen((name) {
      _deck = _deck.rebuild((b) => b.name = name);
      _doDeckChangedController.add(_deck);
    });

    _onDeleteDeckController.stream.listen((_) async {
      try {
        await _delete();
        notifyPop();
      } catch (e, stackTrace) {
        unawaited(error_reporting.report('deleteDeck', e, stackTrace));
        notifyErrorOccurred(e);
      }
    });

    _onDeleteDeckIntention.stream.listen((_) {
      String deleteDeckQuestion;
      switch (_deck.access) {
        case AccessType.owner:
          deleteDeckQuestion = locale.deleteDeckOwnerAccessQuestion;
          break;
        case AccessType.write:
        case AccessType.read:
          deleteDeckQuestion = locale.deleteDeckWriteReadAccessQuestion;
          break;
      }
      _doShowConfirmationDialogController.add(deleteDeckQuestion);
    });

    _onDeckTypeController.stream.listen((deckType) {
      _deck = _deck.rebuild((b) => b.type = deckType);
      _doDeckChangedController.add(_deck);
    });

    _onMarkdownController.stream.listen((markdown) {
      _deck = _deck.rebuild((b) => b.markdown = markdown);
      _doDeckChangedController.add(_deck);
    });
  }

  Future<void> _delete() {
    unawaited(logDeckDelete(_deck.key));
    return user.deleteDeck(deck: _deck);
  }

  @override
  @protected
  Future<bool> userClosesScreen() => _saveDeckSettings();

  Future<bool> _saveDeckSettings() async {
    try {
      await user.updateDeck(deck: _deck);
      return true;
    } catch (e, stackTrace) {
      unawaited(error_reporting.report('updateDeck', e, stackTrace));
      notifyErrorOccurred(e);
    }
    return false;
  }

  @override
  void dispose() {
    _onDeckNameController.close();
    _onDeleteDeckController.close();
    _onDeleteDeckIntention.close();
    _doShowConfirmationDialogController.close();
    _onDeckTypeController.close();
    _onMarkdownController.close();
    _doDeckChangedController.close();
    super.dispose();
  }
}
