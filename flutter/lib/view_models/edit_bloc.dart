import 'dart:async';

import 'package:delern_flutter/models/base/delayed_initialization.dart';
import 'package:delern_flutter/models/base/transaction.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/card_reply_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/filtered_sorted_observable_list.dart';
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

class EditBloc extends ScreenBloc {
  final DeckModel _deck;

  DelayedInitializationObservableList<CardModel> get list => _list;
  final FilteredSortedObservableList<CardModel> _list;

  set filter(Filter<CardModel> newValue) => _list.filter = newValue;
  Filter<CardModel> get filter => _list.filter;

  EditBloc({@required DeckModel deck})
      : assert(deck != null),
        _deck = deck,
        _list =
            // Analyzer bug: https://github.com/dart-lang/sdk/issues/35577.
            // ignore: unnecessary_parenthesis
            (FilteredSortedObservableList(CardModel.getList(deckKey: deck.key))
              ..comparator = (c1, c2) =>
                  c1.front.toLowerCase().compareTo(c2.front.toLowerCase())) {
    _initListeners();
  }

  final _onDeckNameController = StreamController<String>();
  Sink<String> get onDeckName => _onDeckNameController.sink;

  final _onDeleteDeckController = StreamController<void>();
  Sink<void> get onDeleteDeck => _onDeleteDeckController.sink;

  final _onDeleteDeckIntention = StreamController<void>();
  Sink<void> get onDeleteDeckIntention => _onDeleteDeckIntention.sink;

  final _doShowConfirmationDialogController = BehaviorSubject<String>();
  Stream<String> get doShowDeleteConfirmationDialog =>
      _doShowConfirmationDialogController.stream;

  final _doDeckChangedController = BehaviorSubject<DeckModel>();
  Stream<DeckModel> get doDeckChanged => _doDeckChangedController.stream;

  final _onDeckTypeController = StreamController<DeckType>();
  Sink<DeckType> get onDeckType => _onDeckTypeController.sink;

  final _onMarkdownController = StreamController<bool>();
  Sink<bool> get onMarkdown => _onMarkdownController.sink;

  final _doCloseDialogController = BehaviorSubject<void>();
  Stream<void> get doCloseDialog => _doCloseDialogController.stream;

  void _initListeners() {
    _onDeckNameController.stream.listen((name) {
      _deck.name = name;
      _doDeckChangedController.add(_deck);
    });

    _doDeckChangedController.add(_deck);
    _onDeleteDeckController.stream.listen((_) async {
      try {
        await _delete();
        _doCloseDialogController.add(null);
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
      _deck.type = deckType;
      _doDeckChangedController.add(_deck);
    });

    _onMarkdownController.stream.listen((markdown) {
      _deck.markdown = markdown;
      _doDeckChangedController.add(_deck);
    });
  }

  Future<void> _delete() async {
    unawaited(logDeckDelete(_deck.key));
    final t = Transaction()..delete(_deck);
    final card = CardModel(deckKey: _deck.key);
    if (_deck.access == AccessType.owner) {
      final accessList = DeckAccessModel.getList(deckKey: _deck.key);
      await accessList.fetchFullValue();
      accessList
          .forEach((a) => t.delete(DeckModel(uid: a.key)..key = _deck.key));
      t..deleteAll(DeckAccessModel(deckKey: _deck.key))..deleteAll(card);
      // TODO(dotdoom): delete other users' ScheduledCard and Views?
    }
    t
      ..deleteAll(ScheduledCardModel(deckKey: _deck.key, uid: _deck.uid))
      ..deleteAll((CardReplyModelBuilder()
            ..uid = _deck.uid
            ..deckKey = _deck.key
            ..cardKey = null)
          .build());
    await t.commit();
  }

  @override
  @protected
  Future<bool> userClosesScreen() => _saveDeckSettings();

  Future<bool> _saveDeckSettings() async {
    try {
      await (Transaction()..save(_deck)).commit();
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
    _doCloseDialogController.close();
    super.dispose();
  }
}
