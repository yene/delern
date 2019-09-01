import 'dart:async';

import 'package:delern_flutter/models/base/data_writer.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/view_models/base/screen_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

class DeckSettingsBloc extends ScreenBloc {
  final DeckModel _deck;
  String _deckName;
  DeckType _deckType;
  bool _markdown;

  DeckSettingsBloc({@required User user, @required DeckModel deck})
      : assert(deck != null),
        _deck = deck,
        super(user) {
    _deckName = deck.name;
    _deckType = deck.type;
    _markdown = deck.markdown;
    _initListeners();
  }

  final _onDeleteDeckController = StreamController<void>();
  Sink<void> get onDeleteDeck => _onDeleteDeckController.sink;

  final _onDeleteDeckIntention = StreamController<void>();
  Sink<void> get onDeleteDeckIntention => _onDeleteDeckIntention.sink;

  final _doShowConfirmationDialogController = StreamController<String>();
  Stream<String> get doShowConfirmationDialog =>
      _doShowConfirmationDialogController.stream;

  final _onDeckNameController = StreamController<String>();
  Sink<String> get onDeckName => _onDeckNameController.sink;

  final _onDeckTypeController = StreamController<DeckType>();
  Sink<DeckType> get onDeckType => _onDeckTypeController.sink;

  final _onMarkdownController = StreamController<bool>();
  Sink<bool> get onMarkdown => _onMarkdownController.sink;

  Future<void> _delete() {
    unawaited(logDeckDelete(_deck.key));
    return DataWriter(uid: _deck.uid).deleteDeck(deck: _deck);
  }

  Future<void> _save() => DataWriter(uid: _deck.uid).updateDeck(deck: _deck);

  @override
  void dispose() {
    _onDeleteDeckController.close();
    _onDeleteDeckIntention.close();
    _doShowConfirmationDialogController.close();
    _onDeckTypeController.close();
    _onDeckNameController.close();
    _onMarkdownController.close();
    super.dispose();
  }

  Future<bool> _saveDeckSettings() async {
    _deck
      ..name = _deckName
      ..markdown = _markdown
      ..type = _deckType;
    try {
      await _save();
      return true;
    } catch (e, stackTrace) {
      unawaited(error_reporting.report('updateDeck', e, stackTrace));
      notifyErrorOccurred(e);
    }
    return false;
  }

  void _initListeners() {
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

    _onDeckNameController.stream.listen((name) => _deckName = name);

    _onDeckTypeController.stream.listen((deckType) => _deckType = deckType);

    _onMarkdownController.stream.listen((markdown) => _markdown = markdown);
  }

  @override
  @protected
  Future<bool> userClosesScreen() => _saveDeckSettings();
}
