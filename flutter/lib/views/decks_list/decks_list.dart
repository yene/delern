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
import 'package:pedantic/pedantic.dart';

class DecksList extends StatefulWidget {
  final String title;

  const DecksList({@required this.title, Key key})
      : assert(title != null),
        super(key: key);

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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: SearchBarWidget(title: widget.title, search: setFilter),
        drawer: NavigationDrawer(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ObservingAnimatedListWidget<DeckModel>(
                list: _bloc.decksList,
                itemBuilder: (context, item, animation, index) =>
                    SizeTransition(
                      sizeFactor: animation,
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: index == 0 ? _kItemsPadding * 2 : 0),
                          child: DeckListItemWidget(item, _bloc)),
                    ),
                emptyMessageBuilder: () => ArrowToFloatingActionButtonWidget(
                    fabKey: fabKey,
                    child: EmptyListMessageWidget(
                        localizations.of(context).emptyDecksList)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: CreateDeckWidget(key: fabKey),
            )
          ],
        ),
        //floatingActionButton: CreateDeckWidget(key: fabKey),
      );
}

const double _kItemsPadding = 6;

class DeckListItemWidget extends StatelessWidget {
  final DeckModel deck;
  final DecksListBloc bloc;

  const DeckListItemWidget(this.deck, this.bloc);

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildNumberOfCards(context),
                Expanded(
                  child: _buildDeckName(context),
                ),
                DeckMenu(deck: deck),
              ],
            ),
          ),
        ],
      );

  Widget _buildDeckName(BuildContext context) => Padding(
        padding:
            const EdgeInsets.only(top: _kItemsPadding, bottom: _kItemsPadding),
        child: Material(
          elevation: 4,
          child: InkWell(
            splashColor: Theme.of(context).splashColor,
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
                            card: CardModel(deckKey: deck.key), deck: deck))));
              }
            },
            child: Container(
              alignment: Alignment.centerLeft,
              // Height of item is 10% of screen
              height: (MediaQuery.of(context).size.height * 0.1 >
                      app_styles.kMinimumItemHeight)
                  ? MediaQuery.of(context).size.height * 0.1
                  : app_styles.kMinimumItemHeight,
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.height * 0.01),
              child: Text(
                deck.name,
                style: app_styles.primaryText,
              ),
            ),
          ),
        ),
      );

  Widget _buildNumberOfCards(BuildContext context) => StreamBuilder<int>(
        key: Key(deck.key),
        initialData: bloc.numberOfCardsDue(deck.key).value,
        stream: bloc.numberOfCardsDue(deck.key).stream,
        builder: (context, snapshot) => Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.1,
              child: Text(snapshot.data?.toString() ?? 'N/A',
                  style: app_styles.primaryText),
            ),
      );
}
