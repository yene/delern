import 'dart:async';

import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class CardViewModel {
  CardModel card;
  DeckModel deck;

  CardViewModel({@required this.deck, @required this.card})
      : assert(deck != null),
        assert(card != null);

  CardViewModel._copyFrom(CardViewModel other)
      : card = other.card,
        deck = other.deck;
}

class CardPreviewBloc extends ScreenBloc {
  CardPreviewBloc(
      {@required User user, @required CardModel card, @required DeckModel deck})
      : assert(card != null),
        assert(deck != null),
        super(user) {
    _cardValue = CardViewModel(card: card, deck: deck);
    _initListeners();
  }

  void _initListeners() {
    _onDeleteCardController.stream.listen((_) async {
      try {
        await user.deleteCard(card: _cardValue.card);
        notifyPop();
      } catch (e, stackTrace) {
        unawaited(error_reporting.report('deleteCard', e, stackTrace));
        notifyErrorOccurred(e);
      }
    });
    _onDeleteCardIntentionController.stream.listen((_) {
      if (_isEditAllowed()) {
        _doShowDeleteDialogController.add(locale.deleteCardQuestion);
      } else {
        showMessage(locale.noDeletingWithReadAccessUserMessage);
      }
    });
    _onEditCardIntentionController.stream.listen((_) {
      if (_isEditAllowed()) {
        _doEditCardController.add(null);
      } else {
        showMessage(locale.noEditingWithReadAccessUserMessage);
      }
    });
  }

  final _onDeleteCardController = StreamController<String>();
  Sink<String> get onDeleteCard => _onDeleteCardController.sink;

  final _onDeleteCardIntentionController = StreamController<void>();
  Sink<void> get onDeleteDeckIntention => _onDeleteCardIntentionController.sink;

  final _onEditCardIntentionController = StreamController<void>();
  Sink<void> get onEditCardIntention => _onEditCardIntentionController.sink;

  final _doEditCardController = StreamController<void>();
  Stream get doEditCard => _doEditCardController.stream;

  final _doShowDeleteDialogController = StreamController<String>();
  Stream<String> get doShowDeleteDialog => _doShowDeleteDialogController.stream;

  final _doDeckNameChangedController = StreamController<String>();
  Stream<String> get doDeckNameChanged => _doDeckNameChangedController.stream;

  CardViewModel _cardValue;

  StreamWithValue<CardModel> get card =>
      _cardValue.deck.cards.getItem(_cardValue.card.key);

  bool _isEditAllowed() => _cardValue.deck.access != AccessType.read;

  @override
  void dispose() {
    _onDeleteCardController.close();
    _onDeleteCardIntentionController.close();
    _doShowDeleteDialogController.close();
    _doDeckNameChangedController.close();
    _onEditCardIntentionController.close();
    _doEditCardController.close();
    super.dispose();
  }
}
