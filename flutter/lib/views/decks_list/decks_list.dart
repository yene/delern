import 'dart:math';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/decks_list_bloc.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/cards_learning/cards_learning.dart';
import 'package:delern_flutter/views/decks_list/create_deck_widget.dart';
import 'package:delern_flutter/views/decks_list/deck_menu.dart';
import 'package:delern_flutter/views/decks_list/navigation_drawer.dart';
import 'package:delern_flutter/views/helpers/empty_list_message_widget.dart';
import 'package:delern_flutter/views/helpers/observing_animated_list_widget.dart';
import 'package:delern_flutter/views/helpers/search_bar_widget.dart';
import 'package:delern_flutter/views/helpers/sign_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

const double _kItemElevation = 4;
const double _kItemPaddingRatio = _kItemHeightRatio * 0.08;
const double _kItemHeightRatio = 0.1;

class DecksList extends StatefulWidget {
  const DecksList();

  @override
  _DecksListState createState() => _DecksListState();
}

class _ArrowToFloatingActionButton extends CustomPainter {
  final BuildContext scaffoldContext;
  final GlobalKey fabKey;

  _ArrowToFloatingActionButton(this.scaffoldContext, this.fabKey);

  static const _margin = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox scaffoldBox = scaffoldContext.findRenderObject();
    final RenderBox fabBox = fabKey.currentContext.findRenderObject();
    final fabRect =
        scaffoldBox.globalToLocal(fabBox.localToGlobal(Offset.zero)) &
            fabBox.size;
    final center = size.center(Offset.zero);

    final curve = Path()
      ..moveTo(center.dx, center.dy + _margin)
      ..cubicTo(
          center.dx - _margin,
          center.dy + _margin * 2,
          _margin - center.dx,
          (fabRect.center.dy - center.dy) * 2 / 3 + center.dy,
          fabRect.centerLeft.dx - _margin,
          fabRect.center.dy)
      ..moveTo(fabRect.centerLeft.dx - _margin, fabRect.center.dy)
      ..lineTo(
          fabRect.centerLeft.dx - _margin * 2.5, fabRect.center.dy - _margin)
      ..moveTo(fabRect.centerLeft.dx - _margin, fabRect.center.dy)
      ..lineTo(fabRect.centerLeft.dx - _margin * 2.5,
          fabRect.center.dy + _margin / 2);

    canvas.drawPath(
        curve,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_ArrowToFloatingActionButton oldDelegate) =>
      scaffoldContext != oldDelegate.scaffoldContext ||
      fabKey != oldDelegate.fabKey;
}

class ArrowToFloatingActionButtonWidget extends StatelessWidget {
  final Widget child;
  final GlobalKey fabKey;

  const ArrowToFloatingActionButtonWidget({@required this.fabKey, this.child});

  @override
  Widget build(BuildContext context) => Container(
      child: CustomPaint(
          painter: _ArrowToFloatingActionButton(context, fabKey),
          child: child));
}

class _DecksListState extends State<DecksList> {
  DecksListBloc _bloc;

  @override
  void didChangeDependencies() {
    final uid = CurrentUserWidget.of(context).user.uid;
    if (_bloc?.uid != uid) {
      _bloc?.dispose();
      _bloc = DecksListBloc(uid: uid);
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
                      MediaQuery.of(context).size.height * _kItemHeightRatio,
                      app_styles.kMinItemHeight);
                  return SizeTransition(
                      sizeFactor: animation,
                      child: Column(
                        children: <Widget>[
                          if (index == 0)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      _kItemPaddingRatio *
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
                                    _kItemPaddingRatio),
                          ),
                          if (index == (_bloc.decksList.length - 1))
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      _kItemPaddingRatio),
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
        floatingActionButton: CreateDeckWidget(key: fabKey),
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
    return EditDeleteDismissible(
      iconSize: iconSize,
      deck: deck,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          emptyExpanded,
          Expanded(
            flex: 8,
            child: Material(
              elevation: _kItemElevation,
              child: InkWell(
                onTap: () async {
                  final anyCardsShown = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/decks/learn'),
                        // TODO(dotdoom): pass scheduled cards list to
                        //  CardsLearning.
                        builder: (context) => CardsLearning(deck: deck),
                      ));
                  if (anyCardsShown == false) {
                    // If deck is empty, open a screen with adding cards
                    unawaited(Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: const RouteSettings(name: '/cards/new'),
                            builder: (context) => CardCreateUpdate(
                                card: CardModel(deckKey: deck.key),
                                deck: deck))));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: <Widget>[
                      _buildLeading(iconSize),
                      Expanded(child: _buildContent(context)),
                      _buildTrailing(iconSize),
                    ],
                  ),
                ),
              ),
            ),
          ),
          emptyExpanded,
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final primaryTextStyle = app_styles.primaryText.copyWith(
        fontSize: max(minHeight * 0.25, app_styles.kMinPrimaryTextSize));
    final secondaryTextStyle = app_styles.secondaryText.copyWith(
        fontSize: max(minHeight * 0.1, app_styles.kMinSecondaryTextSize));
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
        onPressed: null,
        icon: Icon(Icons.folder),
        iconSize: size,
        color: app_styles.kIconColor,
      );

  Widget _buildTrailing(double size) => DeckMenu(
        deck: deck,
        buttonSize: size,
      );
}

class EditDeleteDismissible extends StatelessWidget {
  final Widget child;
  final DeckModel deck;
  final double iconSize;

  const EditDeleteDismissible(
      {@required this.child, @required this.deck, @required this.iconSize})
      : assert(child != null),
        assert(deck != null),
        assert(iconSize != null);

  @override
  Widget build(BuildContext context) => Dismissible(
        direction: DismissDirection.horizontal,
        resizeDuration: Duration(seconds: 1),
        background: Container(
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            print('Delete');
          }
        },
        confirmDismiss: (direction) {
          if (direction == DismissDirection.startToEnd) {
            // TODO(ksheremet): implement edit screen
            return Future.value(false);
          }
          if (direction == DismissDirection.endToStart) {
            print('End to Start');
            return Future.value(true);
          }
        },
        key: Key(deck.key),
        child: child,
      );
}
