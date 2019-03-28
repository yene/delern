import 'dart:collection';

import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/cards_list/cards_list.dart';
import 'package:delern_flutter/views/deck_settings/deck_settings.dart';
import 'package:delern_flutter/views/deck_sharing/deck_sharing.dart';
import 'package:delern_flutter/views/helpers/sign_in_widget.dart';
import 'package:flutter/material.dart';

const double _iconSize = 48;
const double _menuExpandedSize = 225.0;

class DeckMenu extends StatefulWidget {
  final DeckModel deck;

  const DeckMenu({@required this.deck});

  @override
  State<StatefulWidget> createState() => _DeckMenuState();
}

class _DeckMenuState extends State<DeckMenu>
    with SingleTickerProviderStateMixin {
  Animation<Alignment> _moveAnimation;
  Animation<double> _opacityAnimation;
  AnimationController _controller;
  final duration = Duration(milliseconds: 270);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);

    final anim = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _moveAnimation = Tween<Alignment>(
            begin: Alignment.centerRight, end: Alignment.bottomRight)
        .animate(anim);
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(anim);
  }

  Widget _buildMenuItem(_DeckMenuItemType type, String menuItemName) =>
      RaisedButton(
        // TODO(ksheremet): Set color from styles
        color: Colors.greenAccent[100],
        padding: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Text(menuItemName),
        onPressed: () {
          _controller.reverse().then((_) {
            icon = Icons.more_vert;
            _overlayEntry.remove();
            _onDeckMenuItemSelected(context, type);
          });
        },
      );

  Widget _buildMenuIcon(IconData source) => Material(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: _iconSize,
          height: _iconSize,
          child: Icon(
            source,
          ),
        ),
      );

  OverlayEntry _overlayEntry;
  var icon = Icons.more_vert;

  // TODO(ksheremet): Consider to have a new Route to disable other buttons
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    var rightOffset = _iconSize;
    var topOffset =
        (MediaQuery.of(context).size.height > (_menuExpandedSize + offset.dy))
            ? offset.dy
            : MediaQuery.of(context).size.height - _menuExpandedSize - 8;

    final menu = _buildMenu(context);

    return OverlayEntry(
        builder: (context) => Positioned(
              right: rightOffset,
              top: topOffset,
              height: _menuExpandedSize,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: menu.entries
                          .map((entry) => FadeTransition(
                                opacity: _opacityAnimation,
                                child: Align(
                                    alignment: _moveAnimation.value,
                                    child: Container(
                                        padding: EdgeInsets.only(
                                            bottom: (menu.length -
                                                    1 -
                                                    entry.key.index) *
                                                45.0),
                                        child: _buildMenuItem(
                                            entry.key, entry.value))),
                              ))
                          .toList(),
                    ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        if (_controller.isCompleted) {
          setState(() {
            _controller.reverse().then((_) {
              _overlayEntry.remove();
            });
            icon = Icons.more_vert;
          });
        } else {
          setState(() {
            icon = Icons.close;
            _overlayEntry = _createOverlayEntry();
            var state = Overlay.of(context)..insert(_overlayEntry);
            if (state.mounted) {
              _controller.forward();
            }
          });
        }
      },
      child: _buildMenuIcon(icon));

  void _onDeckMenuItemSelected(BuildContext context, _DeckMenuItemType item) {
    // Not allow to add/edit or delete cards with read access
    // If some error occurred and it is null access
    // we still give a try to edit for a user. If user
    // doesn't have permissions they will see "Permission
    // denied".
    var allowEdit = widget.deck.access != AccessType.read;
    switch (item) {
      case _DeckMenuItemType.add:
        if (allowEdit) {
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
              AppLocalizations.of(context).noAddingWithReadAccessUserMessage);
        }
        break;
      case _DeckMenuItemType.edit:
        Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: '/decks/view'),
              builder: (context) => CardsList(
                    deck: widget.deck,
                    allowEdit: allowEdit,
                  )),
        );
        break;
      case _DeckMenuItemType.setting:
        Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: '/decks/settings'),
              builder: (context) => DeckSettings(widget.deck)),
        );
        break;
      case _DeckMenuItemType.share:
        if (widget.deck.access == AccessType.owner) {
          Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: '/decks/share'),
                builder: (context) => DeckSharing(widget.deck)),
          );
        } else {
          UserMessages.showMessage(Scaffold.of(context),
              AppLocalizations.of(context).noSharingAccessUserMessage);
        }
        break;
    }
  }
}

enum _DeckMenuItemType { add, edit, setting, share }

Map<_DeckMenuItemType, String> _buildMenu(BuildContext context) {
  // We want this Map to be ordered.
  // ignore: prefer_collection_literals
  var deckMenu = LinkedHashMap<_DeckMenuItemType, String>()
    ..[_DeckMenuItemType.add] = AppLocalizations.of(context).addCardsDeckMenu
    ..[_DeckMenuItemType.edit] = AppLocalizations.of(context).editCardsDeckMenu
    ..[_DeckMenuItemType.setting] =
        AppLocalizations.of(context).settingsDeckMenu;

  if (!CurrentUserWidget.of(context).user.isAnonymous) {
    deckMenu[_DeckMenuItemType.share] =
        AppLocalizations.of(context).shareDeckMenu;
  }
  return deckMenu;
}
