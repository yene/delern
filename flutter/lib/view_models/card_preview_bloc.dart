import 'dart:async';

import 'package:delern_flutter/models/base/transaction.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';

class CardViewModel {
  CardModel card;
  DeckModel deck;

  CardViewModel({@required this.deck, this.card}) : assert(deck != null) {
    card ??= CardModel(deckKey: deck.key);
  }

  CardViewModel._copyFrom(CardViewModel other)
      : card = CardModel.copyFrom(other.card),
        deck = DeckModel.copyFrom(other.deck);
}

class CardPreviewBloc extends ScreenBloc {
  CardPreviewBloc({@required CardModel card, @required DeckModel deck})
      : assert(card != null),
        assert(deck != null) {
    _cardValue = CardViewModel(card: card, deck: deck);
    _initListeners();
  }

  void _initListeners() {
    _onDeleteCardController.stream.listen((uid) async {
      try {
        await _deleteCard(uid);
        notifyPop();
      } catch (e, stackTrace) {
        error_reporting.report('deleteCard', e, stackTrace);
        notifyErrorOccurred(e);
      }
    });
    _onDeckNameController.stream.listen(_doDeckNameChangedController.add);
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

  final _onDeckNameController = StreamController<String>();
  Sink<String> get onDeckName => _onDeckNameController.sink;

  final _doDeckNameChangedController = StreamController<String>();
  Stream<String> get doDeckNameChanged => _doDeckNameChangedController.stream;

  CardViewModel _cardValue;
  CardViewModel get cardValue => CardViewModel._copyFrom(_cardValue);

  Stream<CardViewModel> get cardStream =>
      // TODO(dotdoom): mux in DeckModel updates stream, too.
      CardModel.get(deckKey: _cardValue.card.deckKey, key: _cardValue.card.key)
          .transform(StreamTransformer.fromHandlers(
              handleData: (cardModel, sink) async {
        if (cardModel.key == null) {
          // Card doesn't exist anymore. Do not send any events
          sink.close();
        } else {
          sink.add(CardViewModel._copyFrom(_cardValue =
              CardViewModel(card: cardModel, deck: _cardValue.deck)));
        }
      }));

  Future<void> _deleteCard(String uid) => (Transaction()
        ..delete(_cardValue.card)
        ..delete(ScheduledCardModel(deckKey: _cardValue.deck.key, uid: uid)
          ..key = _cardValue.card.key))
      .commit();

  bool _isEditAllowed() => cardValue.deck.access != AccessType.read;

  @override
  void dispose() {
    _onDeleteCardController.close();
    _onDeleteCardIntentionController.close();
    _doShowDeleteDialogController.close();
    _onDeckNameController.close();
    _doDeckNameChangedController.close();
    _onEditCardIntentionController.close();
    _doEditCardController.close();
    super.dispose();
  }
}
