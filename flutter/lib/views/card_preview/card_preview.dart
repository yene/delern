import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/card_preview_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/card_display_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/sign_in_widget.dart';
import 'package:flutter/material.dart';

class CardPreview extends StatefulWidget {
  final CardModel card;
  final DeckModel deck;
  // TODO(ksheremet): Consider to get rid of allow edit.
  // allowEdit = deck.access != AccessType.read
  final bool allowEdit;

  const CardPreview(
      {@required this.card, @required this.deck, @required this.allowEdit})
      : assert(card != null),
        assert(deck != null),
        assert(allowEdit != null);

  @override
  State<StatefulWidget> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview> {
  CardPreviewBloc _bloc;

  @override
  void initState() {
    super.initState();
    // TODO(dotdoom): replace with a simple assignment.
    _bloc = CardPreviewBloc(card: widget.card, deck: widget.deck);
    _bloc.doShowConfirmationDialog.listen(_showDeleteCardDialog);
    _bloc.doShowUserMessage.listen(_showUserMessage);
  }

  @override
  void didChangeDependencies() {
    // TODO(ksheremet): Locale must be somewhere in ScreenBlocView
    final locale = AppLocalizations.of(context);
    if (_bloc?.locale != locale) {
      _bloc.onLocale.add(locale);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => ScreenBlocView(
        appBar: AppBar(
          title: StreamBuilder(
              initialData: widget.deck.name,
              stream: _bloc.onDeckNameChanged,
              builder: (context, snapshot) => Text(snapshot.data)),
          actions: <Widget>[
            Builder(
              builder: (context) => IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    _bloc.onDeleteDeckIntention.add(null);
                  }),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<CardViewModel>(
                    stream: _bloc.cardStream,
                    initialData: _bloc.cardValue,
                    builder: (context, snapshot) => CardDisplayWidget(
                        front: snapshot.requireData.card.front,
                        back: snapshot.requireData.card.back,
                        showBack: true,
                        backgroundColor: specifyCardBackground(
                            snapshot.requireData.deck.type,
                            snapshot.requireData.card.back),
                        isMarkdown: snapshot.requireData.deck.markdown))),
            const Padding(padding: EdgeInsets.only(bottom: 100.0))
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
              child: const Icon(Icons.edit),
              onPressed: () {
                if (widget.allowEdit) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          // 'name' is used by Firebase Analytics to log events.
                          // TODO(dotdoom): consider better route names.
                          settings: const RouteSettings(name: '/cards/edit'),
                          builder: (context) => CardCreateUpdate(
                              card: widget.card, deck: widget.deck)));
                } else {
                  UserMessages.showMessage(
                      Scaffold.of(context),
                      AppLocalizations.of(context)
                          .noEditingWithReadAccessUserMessage);
                }
              }),
        ),
        bloc: _bloc,
      );

  void _showDeleteCardDialog(deleteCardQuestion) async {
    var deleteCardDialog = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: deleteCardQuestion,
        yesAnswer: AppLocalizations.of(context).delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
    if (deleteCardDialog) {
      _bloc.onDeleteCard.add(CurrentUserWidget.of(context).user.uid);
    }
  }

  void _showUserMessage(message) {
    UserMessages.showMessage(Scaffold.of(context),
        AppLocalizations.of(context).noDeletingWithReadAccessUserMessage);
  }
}
