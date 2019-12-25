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

class CardPreviewBloc extends ScreenBloc {
  final String _cardKey;
  final String _deckKey;

  CardPreviewBloc({
    @required User user,
    @required String cardKey,
    @required String deckKey,
  })  : assert(cardKey != null),
        assert(deckKey != null),
        _cardKey = cardKey,
        _deckKey = deckKey,
        super(user) {
    _initListeners();
  }

  void _initListeners() {
    _onDeleteCardController.stream.listen((_) async {
      try {
        await user.deleteCard(
            card: user.decks
                .getItem(_deckKey)
                .value
                .cards
                .getItem(_cardKey)
                .value);
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

  StreamWithValue<DeckModel> get deck => user.decks.getItem(_deckKey);

  StreamWithValue<CardModel> get card => deck.value.cards.getItem(_cardKey);

  bool _isEditAllowed() => deck.value.access != AccessType.read;

  @override
  void dispose() {
    _onDeleteCardController.close();
    _onDeleteCardIntentionController.close();
    _doShowDeleteDialogController.close();
    _onEditCardIntentionController.close();
    _doEditCardController.close();
    super.dispose();
  }
}
