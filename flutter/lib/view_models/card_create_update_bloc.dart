import 'dart:async';

import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class CardCreateUpdateBloc extends ScreenBloc {
  final bool isAddOperation;
  bool _addReversedCard = false;
  CardModelBuilder _card;
  bool _isOperationEnabled = true;

  CardCreateUpdateBloc({
    @required User user,
    @required String deckKey,
    String cardKey,
  })  : assert(deckKey != null),
        isAddOperation = cardKey == null,
        super(user) {
    if (cardKey == null) {
      _card = CardModelBuilder()..deckKey = deckKey;
    } else {
      // TODO(dotdoom): wait until the values arrive.
      _card = user.decks
          .getItem(deckKey)
          .value
          .cards
          .getItem(cardKey)
          .value
          .toBuilder();
    }
    _doFrontSideTextController.add(_card.front);
    _doBackSideTextController.add(_card.back);
    _initListeners();
  }

  StreamWithValue<DeckModel> get deck => user.decks.getItem(_card.deckKey);

  final _onSaveCardController = StreamController<void>();
  Sink<void> get onSaveCard => _onSaveCardController.sink;

  final _onFrontSideTextController = StreamController<String>();
  Sink<String> get onFrontSideText => _onFrontSideTextController.sink;

  final _onBackSideTextController = StreamController<String>();
  Sink<String> get onBackSideText => _onBackSideTextController.sink;

  final _addReversedCardController = StreamController<bool>();
  Sink<bool> get onAddReversedCard => _addReversedCardController.sink;

  final _doFrontSideTextController = StreamController<String>();
  Stream<String> get doFrontSideTextController =>
      _doFrontSideTextController.stream;

  final _doBackSideTextController = StreamController<String>();
  Stream<String> get doBackSideTextController =>
      _doBackSideTextController.stream;

  final _doClearInputFieldsController = StreamController<void>();
  Stream<void> get doClearInputFields => _doClearInputFieldsController.stream;

  final _isOperationEnabledController = StreamController<bool>();
  Stream<bool> get isOperationEnabled => _isOperationEnabledController.stream;

  final _doShowConfirmationDialogController = StreamController<void>();
  Stream<void> get doShowConfirmationDialog =>
      _doShowConfirmationDialogController.stream;

  final _onDiscardChangesController = StreamController<void>();
  Sink<void> get onDiscardChanges => _onDiscardChangesController.sink;

  void _initListeners() {
    _onSaveCardController.stream.listen((_) => _processSavingCard());
    _onFrontSideTextController.stream.listen((frontText) {
      _card.front = frontText;
      _checkOperationAvailability();
    });
    _onBackSideTextController.stream.listen((backText) {
      _card.back = backText;
      _checkOperationAvailability();
    });
    _addReversedCardController.stream.listen((addReversed) {
      _addReversedCard = addReversed;
      _checkOperationAvailability();
    });
    _onDiscardChangesController.stream.listen((_) {
      notifyPop();
    });
  }

  Future<void> _createOrUpdateCard() {
    final card = _card.build();
    if (isAddOperation) {
      logCardCreate(card.deckKey);
      return user.createCard(card: card, addReversed: _addReversedCard);
    } else {
      return user.updateCard(card: card);
    }
  }

  Future<void> _disableUI(Future<void> Function() f) async {
    _isOperationEnabled = false;
    _checkOperationAvailability();
    try {
      await f();
    } finally {
      _isOperationEnabled = true;
      _checkOperationAvailability();
    }
  }

  Future<void> _processSavingCard() async {
    try {
      await _disableUI(_createOrUpdateCard);
      if (!isAddOperation) {
        notifyPop();
        return;
      }
      if (_addReversedCard) {
        showMessage(locale.cardAndReversedAddedUserMessage);
      } else {
        showMessage(locale.cardAddedUserMessage);
      }
      _doClearInputFieldsController.add(null);
    } catch (e, stackTrace) {
      unawaited(error_reporting.report('saveCard', e, stackTrace));
      notifyErrorOccurred(e);
    }
  }

  bool _isCardValid() => _addReversedCard
      ? _card.front.trim().isNotEmpty && _card.back.trim().isNotEmpty
      : _card.front.trim().isNotEmpty;

  void _checkOperationAvailability() {
    _isOperationEnabledController.add(_isOperationEnabled && _isCardValid());
  }

  @override
  Future<bool> userClosesScreen() async {
    _doShowConfirmationDialogController.add(null);
    return Future.value(false);
  }

  @override
  void dispose() {
    _onSaveCardController.close();
    _doClearInputFieldsController.close();
    _onFrontSideTextController.close();
    _onBackSideTextController.close();
    _isOperationEnabledController.close();
    _addReversedCardController.close();
    _doShowConfirmationDialogController.close();
    _onDiscardChangesController.close();
    super.dispose();
  }
}
