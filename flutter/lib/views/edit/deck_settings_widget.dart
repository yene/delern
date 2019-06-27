import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/edit_bloc.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:flutter/material.dart';

import 'deck_type_dropdown_widget.dart';

class DeckSettingsWidget extends StatefulWidget {
  final DeckModel deck;
  final EditBloc bloc;

  const DeckSettingsWidget({@required this.deck, @required this.bloc})
      : assert(bloc != null);

  @override
  State<StatefulWidget> createState() => _DeckSettingsWidgetState();
}

class _DeckSettingsWidgetState extends State<DeckSettingsWidget> {
  DeckType _deckType;
  bool _isMarkdown;

  @override
  void initState() {
    widget.bloc.doShowDeleteConfirmationDialog.listen(_showDeleteDeckDialog);
    _deckType = widget.deck.type;
    _isMarkdown = widget.deck.markdown;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final locale = localizations.of(context);
    if (widget.bloc?.locale != locale) {
      widget.bloc.onLocale.add(locale);
    }
    super.didChangeDependencies();
  }

  Future<void> _showDeleteDeckDialog(deleteDeckQuestion) async {
    final deleteDeckDialog = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: deleteDeckQuestion,
        yesAnswer: localizations.of(context).delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
    if (deleteDeckDialog) {
      // Close settings dialog
      Navigator.of(context).pop();
      widget.bloc.onDeleteDeck.add(null);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Text(
                      localizations.of(context).deckType,
                      style: app_styles.secondaryText,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  DeckTypeDropdownWidget(
                    value: _deckType,
                    valueChanged: (newDeckType) => setState(() {
                      _deckType = newDeckType;
                      widget.bloc.onDeckType.add(newDeckType);
                    }),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    localizations.of(context).markdown,
                    style: app_styles.secondaryText,
                  ),
                  Switch(
                    value: _isMarkdown,
                    onChanged: (newValue) {
                      setState(() {
                        _isMarkdown = newValue;
                        widget.bloc.onMarkdown.add(newValue);
                      });
                    },
                  )
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  onPressed: () async {
                    widget.bloc.onDeleteDeckIntention.add(null);
                  },
                  child: Text(localizations.of(context).deleteDeckButton),
                ),
              ),
            ],
          ),
        ),
      );
}
