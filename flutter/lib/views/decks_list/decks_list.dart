import 'dart:math';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/view_models/decks_list_bloc.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/cards_interval_learning/cards_interval_learning.dart';
import 'package:delern_flutter/views/cards_view_learning/cards_view_learning.dart';
import 'package:delern_flutter/views/decks_list/create_deck_widget.dart';
import 'package:delern_flutter/views/decks_list/deck_menu.dart';
import 'package:delern_flutter/views/decks_list/navigation_drawer.dart';
import 'package:delern_flutter/views/edit/edit_screen.dart';
import 'package:delern_flutter/views/helpers/arrow_to_fab_widget.dart';
import 'package:delern_flutter/views/helpers/empty_list_message_widget.dart';
import 'package:delern_flutter/views/helpers/learning_method_widget.dart';
import 'package:delern_flutter/views/helpers/observing_animated_list_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/search_bar_widget.dart';
import 'package:delern_flutter/views/helpers/sign_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

class DecksList extends StatefulWidget {
  const DecksList();

  @override
  _DecksListState createState() => _DecksListState();
}

class _DecksListState extends State<DecksList> {
  // TODO(ksheremet): use ScreenBlocView to handle this bloc.
  DecksListBloc _bloc;

  @override
  void didChangeDependencies() {
    final user = CurrentUserWidget.of(context).user;
    if (_bloc?.user != user) {
      _bloc?.dispose();
      _bloc = DecksListBloc(user: user);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }

  void setFilter(String input) {
    if (input == null) {
      _bloc.decksListFilter = null;
      return;
    }
    input = input.toLowerCase();
    _bloc.decksListFilter = (d) =>
        // Case insensitive filter
        d.name.toLowerCase().contains(input);
  }

  GlobalKey fabKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: SearchBarWidget(
          title: localizations.of(context).listOFDecksScreenTitle,
          search: setFilter,
          leading: IconButton(
            tooltip: localizations.of(context).profileTooltip,
            icon: const Icon(Icons.person),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
        ),
        drawer: NavigationDrawer(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ObservingAnimatedListWidget<DeckModel>(
                list: _bloc.decksList,
                itemBuilder: (context, item, animation, index) {
                  final itemHeight = max(
                      MediaQuery.of(context).size.height *
                          app_styles.kItemListHeightRatio,
                      app_styles.kMinItemHeight);
                  return SizeTransition(
                      sizeFactor: animation,
                      child: Column(
                        children: <Widget>[
                          if (index == 0)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      app_styles.kItemListPaddingRatio *
                                      2),
                            ),
                          DeckListItemWidget(
                            deck: item,
                            bloc: _bloc,
                            minHeight: itemHeight,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.height *
                                    app_styles.kItemListPaddingRatio),
                          ),
                          if (index == (_bloc.decksList.length - 1))
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      app_styles.kItemListPaddingRatio),
                            ),
                        ],
                      ));
                },
                emptyMessageBuilder: () => ArrowToFloatingActionButtonWidget(
                    fabKey: fabKey,
                    child: EmptyListMessageWidget(
                        localizations.of(context).emptyDecksList)),
              ),
            ),
          ],
        ),
        floatingActionButton: CreateDeckWidget(key: fabKey, bloc: _bloc),
      );
}

class DeckListItemWidget extends StatelessWidget {
  final DeckModel deck;
  final DecksListBloc bloc;
  final double minHeight;

  const DeckListItemWidget(
      {@required this.deck, @required this.bloc, @required this.minHeight});

  @override
  Widget build(BuildContext context) {
    final emptyExpanded = Expanded(
      flex: 1,
      child: Container(
        color: Colors.transparent,
      ),
    );

    final iconSize = max(minHeight * 0.5, app_styles.kMinIconHeight);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        emptyExpanded,
        Expanded(
          flex: 8,
          child: EditDeleteDismissible(
            iconSize: iconSize,
            deck: deck,
            onDeleteDismiss: () async {
              if (await _showDeleteDeckDialog(context)) {
                unawaited(logDeckDeleteSwipe(deck.key));
                return _deleteDeck(context);
              }
              return false;
            },
            child: Material(
              elevation: app_styles.kItemElevation,
              child: InkWell(
                onTap: () async {
                  await _showLearningDialog(context);
                },
                child: Row(
                  children: <Widget>[
                    _buildLeading(iconSize),
                    Expanded(child: _buildContent(context)),
                    _buildTrailing(context, iconSize),
                  ],
                ),
              ),
            ),
          ),
        ),
        emptyExpanded,
      ],
    );
  }

  Future _showLearningDialog(BuildContext context) async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      localizations.of(context).learning,
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        LearningMethodWidget(
                          name: localizations.of(context).intervalLearning,
                          tooltip:
                              localizations.of(context).intervalLearningTooltip,
                          icon: Icons.autorenew,
                          onTap: () async {
                            // Close dialog
                            Navigator.pop(context);
                            await _learnCards(
                                context,
                                MaterialPageRoute(
                                  settings:
                                      const RouteSettings(name: '/decks/learn'),
                                  // TODO(dotdoom): pass scheduled cards list to
                                  //  CardsLearning.
                                  builder: (context) =>
                                      CardsIntervalLearning(deck: deck),
                                ));
                          },
                        ),
                        LearningMethodWidget(
                          name: localizations.of(context).viewLearning,
                          tooltip:
                              localizations.of(context).viewLearningTooltip,
                          icon: Icons.remove_red_eye,
                          onTap: () async {
                            // Close dialog
                            Navigator.pop(context);
                            await _learnCards(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(
                                      name: '/decks/learn-view'),
                                  builder: (context) =>
                                      CardsReviewLearning(deck: deck),
                                ));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }

  Future<void> _learnCards(
      BuildContext context, MaterialPageRoute route) async {
    final anyCardsShown = await Navigator.push(context, route);
    if (anyCardsShown == false) {
      // If deck is empty, open a screen with adding cards
      unawaited(Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: '/cards/new'),
              builder: (context) => CardCreateUpdate(
                  card: CardModel(deckKey: deck.key), deck: deck))));
    }
  }

  Widget _buildContent(BuildContext context) {
    final primaryFontSize =
        max(minHeight * 0.25, app_styles.kMinPrimaryTextSize);
    final primaryTextStyle =
        app_styles.primaryText.copyWith(fontSize: primaryFontSize);
    final secondaryTextStyle = app_styles.secondaryText.copyWith(
        fontSize: primaryFontSize / 1.5,
        color: app_styles.kSecondaryTextDeckItemColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          deck.name,
          style: primaryTextStyle,
        ),
        StreamBuilder<int>(
          key: Key(deck.key),
          initialData: bloc.numberOfCardsDue(deck.key).value,
          stream: bloc.numberOfCardsDue(deck.key).stream,
          builder: (context, snapshot) => Container(
            child: Text(
              localizations
                  .of(context)
                  .cardsToLearnLabel(snapshot.data?.toString() ?? 'N/A'),
              style: secondaryTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeading(double size) => IconButton(
        padding: const EdgeInsets.all(app_styles.kIconDeckPadding),
        onPressed: null,
        icon: Icon(
          Icons.folder,
          color: app_styles.kIconColor,
        ),
        iconSize: size,
      );

  Widget _buildTrailing(BuildContext context, double size) => DeckMenu(
        deck: deck,
        buttonSize: size,
        onDeleteDeck: () async {
          if (await _showDeleteDeckDialog(context)) {
            unawaited(logDeckDelete(deck.key));
            await _deleteDeck(context);
          }
        },
      );

  Future<bool> _showDeleteDeckDialog(BuildContext context) {
    final locale = localizations.of(context);
    return showSaveUpdatesDialog(
        context: context,
        changesQuestion: deck.access == AccessType.owner
            ? locale.deleteDeckOwnerAccessQuestion
            : locale.deleteDeckWriteReadAccessQuestion,
        yesAnswer: locale.delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
  }

  Future<bool> _deleteDeck(BuildContext context) async {
    try {
      await bloc.deleteDeck(deck);
      UserMessages.showMessage(Scaffold.of(context),
          localizations.of(context).deckDeletedUserMessage);
      return true;
    } catch (e, stackTrace) {
      unawaited(
          UserMessages.showError(() => Scaffold.of(context), e, stackTrace));
    }
    return false;
  }
}

typedef DeleteDismissibleCallback = Future<bool> Function();

class EditDeleteDismissible extends StatelessWidget {
  final Widget child;
  final DeckModel deck;
  final double iconSize;
  final DeleteDismissibleCallback onDeleteDismiss;

  const EditDeleteDismissible({
    @required this.child,
    @required this.deck,
    @required this.iconSize,
    @required this.onDeleteDismiss,
  })  : assert(child != null),
        assert(deck != null),
        assert(iconSize != null),
        assert(onDeleteDismiss != null);

  @override
  Widget build(BuildContext context) => Dismissible(
        direction: DismissDirection.horizontal,
        resizeDuration: const Duration(seconds: 1),
        background: Container(
          color: app_styles.kEditDismissibleColor,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AspectRatio(
              aspectRatio: 1,
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
        secondaryBackground: Container(
          color: app_styles.kDeleteDismissibleColor,
          alignment: Alignment.centerRight,
          child: AspectRatio(
            aspectRatio: 1,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return onDeleteDismiss();
          }
          unawaited(logDeckEditSwipe(deck.key));
          unawaited(Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: '/decks/view'),
                builder: (context) => EditScreen(
                      deck: deck,
                    )),
          ));
          return false;
        },
        key: Key(deck.key),
        child: child,
      );
}
