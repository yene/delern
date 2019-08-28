import 'dart:async';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/edit_bloc.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:flutter/material.dart';

const double _kBorderPadding = 8;
const double _kMinDeckTypeWidgetWidth = 90;
final _kItemListPadding = Container(width: _kBorderPadding * 2);

final _kMasculineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      app_styles.cardDarkBackgroundColors[Gender.masculine],
      app_styles.cardLightBackgroundColors[Gender.masculine]
    ]);

final _kFeminineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      app_styles.cardDarkBackgroundColors[Gender.feminine],
      app_styles.cardLightBackgroundColors[Gender.feminine]
    ]);

final _kNeuterGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      app_styles.cardDarkBackgroundColors[Gender.neuter],
      app_styles.cardLightBackgroundColors[Gender.neuter]
    ]);

final _kNoGenderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      app_styles.cardDarkBackgroundColors[Gender.noGender],
      app_styles.cardLightBackgroundColors[Gender.noGender]
    ]);

class DeckSettingsWidget extends StatefulWidget {
  final DeckModel deck;
  final EditBloc bloc;

  const DeckSettingsWidget({@required this.deck, @required this.bloc})
      : assert(bloc != null);

  @override
  State<StatefulWidget> createState() => _DeckSettingsWidgetState();
}

class _DeckSettingsWidgetState extends State<DeckSettingsWidget> {
  DeckType _currentDeckType;
  bool _isMarkdown;

  StreamSubscription _deleteDeckSubscription;

  @override
  void initState() {
    _deleteDeckSubscription = widget.bloc.doShowDeleteConfirmationDialog
        .listen(_showDeleteDeckDialog);
    _currentDeckType = widget.deck.type;
    _isMarkdown = widget.deck.markdown;
    super.initState();
  }

  @override
  void dispose() {
    _deleteDeckSubscription.cancel();
    super.dispose();
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
        padding: const EdgeInsets.all(_kBorderPadding),
        child: SingleChildScrollView(
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      localizations.of(context).deckType,
                      style: app_styles.primaryText,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: _kBorderPadding),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBasicDeckType(),
                        _kItemListPadding,
                        _buildGermanDeckType(),
                        _kItemListPadding,
                        _buildSwissDeckType(),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      localizations.of(context).markdown,
                      style: app_styles.primaryText,
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
                RaisedButton(
                  onPressed: () async {
                    widget.bloc.onDeleteDeckIntention.add(null);
                  },
                  child: Text(
                    localizations.of(context).deleteDeckButton,
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildGermanDeckType() {
    final ruleList = [
      // TODO(dotdoom): Refactor: move logic to card_background_specifier
      _buildRule('der', app_styles.cardBackgroundColors[Gender.masculine]),
      _buildRule('die, eine', app_styles.cardBackgroundColors[Gender.feminine]),
      _buildRule('das', app_styles.cardBackgroundColors[Gender.neuter]),
    ];
    return _buildDeckType(DeckType.german, ruleList);
  }

  Widget _buildSwissDeckType() {
    final ruleList = [
      _buildRule('de, en', _kMasculineGradient),
      _buildRule('d, e', _kFeminineGradient),
      _buildRule('s, es', _kNeuterGradient),
    ];
    return _buildDeckType(DeckType.swiss, ruleList);
  }

  Widget _buildBasicDeckType() {
    final ruleList = [
      _buildRule('', _kNoGenderGradient),
      _buildRule('', _kNoGenderGradient),
      _buildRule('', _kNoGenderGradient),
    ];
    return _buildDeckType(DeckType.basic, ruleList);
  }

  Widget _buildDeckType(DeckType deckType, List<Widget> ruleList) => Material(
        color: _currentDeckType == deckType
            ? Colors.grey
            : app_styles.kScaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: InkWell(
          splashColor: Theme.of(context).splashColor,
          onTap: () {
            setState(() {
              _currentDeckType = deckType;
              widget.bloc.onDeckType.add(deckType);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(_kBorderPadding),
            child: Column(
              children: <Widget>[
                Text(_getDeckTypeName(deckType)),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: ruleList,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  String _getDeckTypeName(DeckType deckType) {
    switch (deckType) {
      case DeckType.basic:
        return localizations.of(context).basicDeckType;
      case DeckType.german:
        return localizations.of(context).germanDeckType;
      case DeckType.swiss:
        return localizations.of(context).swissDeckType;
    }
    return localizations.of(context).unknownDeckType;
  }

  Widget _buildRule(String text, Gradient gradient) => ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: _kMinDeckTypeWidgetWidth,
          minHeight: app_styles.kMinSecondaryTextSize + _kBorderPadding,
        ),
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          padding: const EdgeInsets.all(_kBorderPadding),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: app_styles.kMinSecondaryTextSize,
            ),
          ),
        ),
      );
}
