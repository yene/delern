import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/routes.dart';
import 'package:delern_flutter/view_models/card_preview_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/card_display_widget.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:flutter/material.dart';

class CardPreview extends StatefulWidget {
  static const routeName = '/cards/preview';

  static Map<String, String> buildArguments({
    @required String deckKey,
    @required String cardKey,
  }) =>
      {
        'deckKey': deckKey,
        'cardKey': cardKey,
      };

  const CardPreview() : super();

  @override
  State<StatefulWidget> createState() => _CardPreviewState();
}

class _CardPreviewState extends State<CardPreview> {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> arguments =
        ModalRoute.of(context).settings.arguments;
    final cardKey = arguments['cardKey'], deckKey = arguments['deckKey'];
    return ScreenBlocView<CardPreviewBloc>(
      blocBuilder: (user) {
        final bloc =
            CardPreviewBloc(user: user, cardKey: cardKey, deckKey: deckKey);
        bloc.doShowDeleteDialog
            .listen((message) => _showDeleteCardDialog(bloc, message));
        bloc.doEditCard.listen((_) => openEditCardScreen(
              context,
              deckKey: deckKey,
              cardKey: cardKey,
            ));
        return bloc;
      },
      appBarBuilder: (bloc) => AppBar(
        title: buildStreamBuilderWithValue<DeckModel>(
          // TODO(dotdoom): better handle deck removal events.
          streamWithValue: bloc.deck,
          builder: (context, snapshot) => snapshot.hasData
              ? Text(snapshot.data.name)
              : ProgressIndicatorWidget(),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: localizations.of(context).deleteCardTooltip,
            icon: const Icon(Icons.delete),
            onPressed: () async => bloc.onDeleteDeckIntention.add(null),
          ),
        ],
      ),
      bodyBuilder: (bloc) => Column(
        children: <Widget>[
          Expanded(
            child: buildStreamBuilderWithValue<DeckModel>(
              streamWithValue: bloc.deck,
              // TODO(dotdoom): better handle deck removal events.
              builder: (context, deckSnapshot) => deckSnapshot.hasData
                  ? buildStreamBuilderWithValue<CardModel>(
                      streamWithValue: bloc.card,
                      // TODO(dotdoom): better handle card removal events.
                      builder: (context, cardSnapshot) => cardSnapshot.hasData
                          ? CardDisplayWidget(
                              front: cardSnapshot.data.frontWithoutTags,
                              frontImages: cardSnapshot.data.frontImagesUri,
                              tags: cardSnapshot.data.tags.toList(),
                              back: cardSnapshot.data.back,
                              backImages: cardSnapshot.data.backImagesUri,
                              showBack: true,
                              color: specifyCardColors(
                                deckSnapshot.data.type,
                                cardSnapshot.data.back,
                              ).defaultBackground,
                            )
                          : ProgressIndicatorWidget(),
                    )
                  : ProgressIndicatorWidget(),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 100))
        ],
      ),
      floatingActionButtonBuilder: (bloc) => FloatingActionButton(
        tooltip: localizations.of(context).editCardTooltip,
        onPressed: () => bloc.onEditCardIntention.add(null),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Future<void> _showDeleteCardDialog(
      CardPreviewBloc bloc, String deleteCardQuestion) async {
    final deleteCardDialog = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: deleteCardQuestion,
        yesAnswer: localizations.of(context).delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
    if (deleteCardDialog) {
      bloc.onDeleteCard.add(null);
    }
  }
}
