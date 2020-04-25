import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/routes.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:flutter/material.dart';

class CardActionsMenuWidget extends StatelessWidget {
  final User user;
  final DeckModel deck;
  final CardModel card;

  const CardActionsMenuWidget({
    @required this.user,
    @required this.deck,
    @required this.card,
    Key key,
  })  : assert(user != null),
        assert(deck != null),
        assert(card != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => PopupMenuButton<_CardMenuItemType>(
        tooltip: context.l.menuTooltip,
        onSelected: (itemType) => _onCardMenuItemSelected(
          context: context,
          menuItem: itemType,
        ),
        itemBuilder: (context) => [
          for (final entry in _buildMenu(context).entries)
            PopupMenuItem<_CardMenuItemType>(
              value: entry.key,
              child: Text(entry.value),
            ),
        ],
      );

  void _onCardMenuItemSelected({
    @required BuildContext context,
    @required _CardMenuItemType menuItem,
  }) {
    switch (menuItem) {
      case _CardMenuItemType.edit:
        if (deck.access != AccessType.read) {
          openEditCardScreen(
            context,
            deckKey: deck.key,
            cardKey: card.key,
          );
        } else {
          UserMessages.showMessage(Scaffold.of(context),
              context.l.noEditingWithReadAccessUserMessage);
        }
        break;
      case _CardMenuItemType.delete:
        if (deck.access != AccessType.read) {
          _deleteCard(context: context);
        } else {
          UserMessages.showMessage(Scaffold.of(context),
              context.l.noDeletingWithReadAccessUserMessage);
        }
        break;
    }
  }

  Future<void> _deleteCard({
    @required BuildContext context,
  }) async {
    // Extract values from context before async gap might destroy it.
    final scaffold = Scaffold.of(context), locale = context.l;
    final saveChanges = await showSaveUpdatesDialog(
        context: context,
        changesQuestion: locale.deleteCardQuestion,
        yesAnswer: locale.delete,
        noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
    if (saveChanges) {
      try {
        await user.deleteCard(card: card);
        UserMessages.showMessage(scaffold, locale.cardDeletedUserMessage);
      } catch (e, stackTrace) {
        UserMessages.showAndReportError(
          () => scaffold,
          e,
          stackTrace: stackTrace,
        );
      }
    }
  }
}

enum _CardMenuItemType { edit, delete }

Map<_CardMenuItemType, String> _buildMenu(BuildContext context) => {
      _CardMenuItemType.edit: context.l.edit,
      _CardMenuItemType.delete: context.l.delete,
    };
