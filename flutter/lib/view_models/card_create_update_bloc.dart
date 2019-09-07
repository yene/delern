import 'dart:async';

import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class CardCreateUpdateBloc extends ScreenBloc {
  String _frontText;
  String _backText;
  bool _addReversedCard = false;
  CardModel _cardModel;
  final bool isAddOperation;
  bool _isOperationEnabled = true;

  CardCreateUpdateBloc({@required User user, @required cardModel})
      : assert(cardModel != null),
        isAddOperation = cardModel.key == null,
        super(user) {
    _cardModel = cardModel;
    _initFields();
    _initListeners();
  }

  final _onSaveCardController = StreamController<void>();
  Sink<void> get onSaveCard => _onSaveCardController.sink;

  final _onFrontSideTextController = StreamController<String>();
  Sink<String> get onFrontSideText => _onFrontSideTextController.sink;

  final _onBackSideTextController = StreamController<String>();
  Sink<String> get onBackSideText => _onBackSideTextController.sink;

  final _addReversedCardController = StreamController<bool>();
  Sink<bool> get onAddReversedCard => _addReversedCardController.sink;

  final _doClearInputFieldsController = StreamController<void>();
  Stream<void> get doClearInputFields => _doClearInputFieldsController.stream;

  final _isOperationEnabledController = StreamController<bool>();
  Stream<bool> get isOperationEnabled => _isOperationEnabledController.stream;

  final _doShowConfirmationDialogController = StreamController<void>();
  Stream<void> get doShowConfirmationDialog =>
      _doShowConfirmationDialogController.stream;

  final _onDiscardChangesController = StreamController<void>();
  Sink<void> get onDiscardChanges => _onDiscardChangesController.sink;

  void _initFields() {
    _frontText = _cardModel.front ?? '';
    _backText = _cardModel.back ?? '';
  }

  void _initListeners() {
    _onSaveCardController.stream.listen((_) => _processSavingCard());
    _onFrontSideTextController.stream.listen((frontText) {
      _frontText = frontText;
      _checkOperationAvailability();
    });
    _onBackSideTextController.stream.listen((backText) {
      _backText = backText;
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
    if (isAddOperation) {
      logCardCreate(_cardModel.deckKey);
      return user.createCard(card: _cardModel, addReversed: _addReversedCard);
    } else {
      return user.updateCard(card: _cardModel);
    }
  }

  Future<void> _disableUI(Future<void> Function() f) async {
    _isOperationEnabled = false;
    _isOperationEnabledController.add(_isOperationEnabled);
    try {
      await f();
    } finally {
      _isOperationEnabled = true;
      _isOperationEnabledController.add(_isOperationEnabled);
    }
  }

  Future<void> _processSavingCard() async {
    _cardModel
      ..front = _frontText.trim()
      ..back = _backText.trim();
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
      ? _frontText.trim().isNotEmpty && _backText.trim().isNotEmpty
      : _frontText.trim().isNotEmpty;

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
