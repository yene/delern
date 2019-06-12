import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/edit_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/card_preview/card_preview.dart';
import 'package:delern_flutter/views/cards_list/observing_grid_widget.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/search_bar_widget.dart';
import 'package:flutter/material.dart';

class CardsList extends StatefulWidget {
  final DeckModel deck;

  const CardsList({@required this.deck}) : assert(deck != null);

  @override
  _CardsListState createState() => _CardsListState();
}

class _CardsListState extends State<CardsList> {
  final TextEditingController _deckNameController = TextEditingController();
  EditBloc _bloc;

  void _searchTextChanged(String input) {
    if (input == null) {
      _bloc.filter = null;
      return;
    }
    input = input.toLowerCase();
    _bloc.filter = (c) =>
        c.front.toLowerCase().contains(input) ||
        c.back.toLowerCase().contains(input);
  }

  @override
  void initState() {
    _bloc = EditBloc(deck: widget.deck);
    _deckNameController.text = widget.deck.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ScreenBlocView(
        appBar: SearchBarWidget(
            // TODO(ksheremet): Localize
            title: 'Edit',
            search: _searchTextChanged),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: _deckNameController,
                style: app_styles.primaryText,
                onChanged: (text) {
                  setState(() {
                    _bloc.onDeckName.add(text);
                  });
                },
              ),
            ),
            Expanded(child: _buildCardGrid()),
          ],
        ),
        floatingActionButton: buildAddCard(),
        bloc: _bloc,
      );

  Widget _buildCardGrid() => ObservingGridWidget<CardModel>(
        maxCrossAxisExtent: 240,
        items: _bloc.list,
        itemBuilder: (item) => CardGridItem(
          card: item,
          deck: widget.deck,
          allowEdit: widget.deck.access != AccessType.read,
        ),
        // TODO(ksheremet): Consider to remove this field
        emptyGridUserMessage: localizations.of(context).emptyCardsList,
      );

  Builder buildAddCard() => Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            if (widget.deck.access != AccessType.read) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: '/cards/new'),
                      builder: (context) => CardCreateUpdate(
                            card: CardModel(deckKey: widget.deck.key),
                            deck: widget.deck,
                          )));
            } else {
              UserMessages.showMessage(Scaffold.of(context),
                  localizations.of(context).noAddingWithReadAccessUserMessage);
            }
          },
          child: const Icon(Icons.add),
        ),
      );

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

class CardGridItem extends StatelessWidget {
  final CardModel card;
  final DeckModel deck;
  final bool allowEdit;

  const CardGridItem(
      {@required this.card, @required this.deck, @required this.allowEdit})
      : assert(card != null),
        assert(deck != null),
        assert(allowEdit != null);

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.transparent,
        child: Material(
          color: specifyCardBackground(deck.type, card.back),
          child: InkWell(
            splashColor: Theme.of(context).splashColor,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: '/cards/preview'),
                    builder: (context) => CardPreview(
                          card: card,
                          deck: deck,
                        ))),
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    card.front,
                    maxLines: 3,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: app_styles.primaryText,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      card.back ?? '',
                      maxLines: 3,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: app_styles.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
