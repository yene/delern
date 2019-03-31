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
  AnimationController _controller;
  final _duration = Duration(milliseconds: 270);
  var _menuIcon = Icons.more_vert;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onMenuExpanded();
        }
        if (status == AnimationStatus.reverse) {
          _onMenuClosed();
        }
      });
  }

  void _onMenuExpanded() {
    setState(() {
      _menuIcon = Icons.close;
    });
  }

  void _onMenuClosed() {
    setState(() {
      _menuIcon = Icons.more_vert;
    });
  }

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

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () async {
        var menuItemType = await Navigator.push(
            context,
            _MenuRoute<_DeckMenuItemType>(
                parent: context,
                child: _MenuItemsWidget(controller: _controller),
                controller: _controller));
        _onMenuClosed();
        if (menuItemType != null) {
          _onDeckMenuItemSelected(context, menuItemType);
        }
      },
      child: _buildMenuIcon(_menuIcon));

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

// TODO(ksheremet): Consider to try different routes
class _MenuRoute<_DeckMenuItemType> extends PopupRoute<_DeckMenuItemType> {
  // We need parent to count position of menu.
  BuildContext parent;

  // TODO(ksheremet): Refactor
  AnimationController controller;

  Widget child;

  _MenuRoute(
      {@required this.parent, @required this.child, @required this.controller})
      : assert(parent != null),
        assert(child != null);

  final duration = Duration(milliseconds: 270);

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  void didComplete(_DeckMenuItemType result) {
    controller.reverse();
    super.didComplete(result);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    RenderBox renderBox = parent.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    var rightOffset = _iconSize;
    var topOffset =
        (MediaQuery.of(context).size.height > (_menuExpandedSize + offset.dy))
            ? offset.dy
            : MediaQuery.of(context).size.height - _menuExpandedSize - 8;

    return Stack(children: <Widget>[
      Positioned(
        right: rightOffset,
        top: topOffset,
        height: _menuExpandedSize,
        child: child,
      )
    ]);
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Animation<double> createAnimation() => CurvedAnimation(
        parent: super.createAnimation(),
        curve: Curves.linear,
        reverseCurve: const Interval(0.0, 200),
      );
}

class _MenuItemsWidget extends StatefulWidget {
  final AnimationController controller;

  const _MenuItemsWidget({@required this.controller});

  @override
  State<StatefulWidget> createState() => _MenuItemsWidgetState();
}

class _MenuItemsWidgetState extends State<_MenuItemsWidget>
    with SingleTickerProviderStateMixin {
  Animation<Alignment> _moveAnimation;
  Animation<double> _opacityAnimation;
  AnimationController _controller;
  final duration = Duration(milliseconds: 270);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    final anim = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _moveAnimation = Tween<Alignment>(
            begin: Alignment.centerRight, end: Alignment.bottomRight)
        .animate(anim);
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(anim);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final menu = _buildMenu(context);
    return AnimatedBuilder(
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
                                  bottom: (menu.length - 1 - entry.key.index) *
                                      45.0),
                              child: _buildMenuItem(entry.key, entry.value))),
                    ))
                .toList(),
          ),
    );
  }

  void finishAnimation() {
    _controller.reverse();
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
            Navigator.pop(context, type);
          });
}
