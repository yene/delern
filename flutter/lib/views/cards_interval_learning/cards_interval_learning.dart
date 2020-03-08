import 'dart:async';

import 'package:delern_flutter/flutter/clock.dart';
import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/analytics.dart';
import 'package:delern_flutter/views/cards_interval_learning/card_actions_menu_widget.dart';
import 'package:delern_flutter/views/cards_interval_learning/card_answer_buttons_widget.dart';
import 'package:delern_flutter/views/helpers/auth_widget.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/text_overflow_ellipsis_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart';

const _kCardPaddingRatio = 0.07;
// Take floating button height from source code: https://bit.ly/2y9aIM6
const BoxConstraints _kFloatingButtonHeightConstraint = BoxConstraints.tightFor(
  height: 56,
);

class CardsIntervalLearning extends StatefulWidget {
  static const routeName = '/learn-interval';

  const CardsIntervalLearning();

  static Map<String, String> buildArguments({
    @required String deckKey,
  }) =>
      {
        'deckKey': deckKey,
      };

  @override
  State<StatefulWidget> createState() => CardsIntervalLearningState();
}

class CardsIntervalLearningState extends State<CardsIntervalLearning> {
  /// Whether the card on the display is scheduled for the time in future.
  /// Implies that the user has been asked to learn cards beyond current date,
  /// and replied positively.
  bool _learnBeyondHorizon = false;

  /// Whether we have shown at least one side of one card to the user (does not
  /// necessarily mean that they answered it).
  bool _atLeastOneCardShown = false;

  /// Number of cards the user has answered (either positively or negatively) to
  /// in this session.
  int _answersCount = 0;

  User _user;
  StreamSubscription<void> _updates;
  StreamWithValue<DeckModel> _deck;
  StreamWithValue<CardModel> _card;
  ScheduledCardModel _scheduledCard;

  final _showReplyButtons = ValueNotifier<bool>(false);

  @override
  void didChangeDependencies() {
    final user = CurrentUserWidget.of(context).user;
    if (_user != user) {
      _user = user;
      _updates?.cancel();

      final Map<String, String> arguments =
          ModalRoute.of(context).settings.arguments;
      final deckKey = arguments['deckKey'];
      _deck = _user.decks.getItem(deckKey);

      _updates ??=
          ScheduledCardModel.next(_user, _deck.value).listen(_nextCardArrived,
              // Tell caller that no cards were available,
              onDone: () => Navigator.of(context).pop());
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _updates?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        // TODO(dotdoom): find out why build triggers twice for next card.
        appBar: AppBar(
          title: buildStreamBuilderWithValue<DeckModel>(
            streamWithValue: _deck,
            builder: (context, snapshot) => snapshot.hasData
                ? TextOverflowEllipsisWidget(
                    textDetails: snapshot.data.name,
                  )
                : ProgressIndicatorWidget(),
          ),
          actions: _card == null
              ? null
              : <Widget>[
                  CardActionsMenuWidget(
                    user: _user,
                    deck: _deck.value,
                    card: _card.value,
                  ),
                ],
        ),
        body: _card == null
            ? ProgressIndicatorWidget()
            : Column(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? EdgeInsets.all(MediaQuery.of(context).size.width *
                            _kCardPaddingRatio)
                        : EdgeInsets.only(
                            top: 10,
                            left: MediaQuery.of(context).size.width *
                                _kCardPaddingRatio,
                            right: MediaQuery.of(context).size.width *
                                _kCardPaddingRatio),
                    child: buildStreamBuilderWithValue<CardModel>(
                        // TODO(dotdoom): find a prettier way to trigger the
                        //                builder() when initialData changes.
                        key: ValueKey(_card.value?.key),
                        streamWithValue: _card,
                        builder: (context, snapshot) {
                          // TODO(dotdoom): handle removed data (in model).
                          if (!snapshot.hasData) {
                            return ProgressIndicatorWidget();
                          }
                          final card = snapshot.data;
                          // TODO(dotdoom): handle card updates.
                          return FlipCardWidget(
                            front: card.frontWithoutTags,
                            back: card.back,
                            colors:
                                specifyCardColors(_deck.value.type, card.back),
                            onFirstFlip: () {
                              _showReplyButtons.value = true;
                            },
                            key: ValueKey(card.key),
                          );
                        }),
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _showReplyButtons,
                      builder: (context, showReplyButtons, child) =>
                          showReplyButtons
                              ? CardAnswerButtonsWidget(
                                  user: _user,
                                  scheduledCard: _scheduledCard,
                                  onAnswer: (knows) {
                                    if (_answersCount == 0) {
                                      unawaited(
                                          logStartLearning(_deck.value.key));
                                    }
                                    unawaited(logCardResponse(
                                      deckId: _deck.value.key,
                                      knows: knows,
                                    ));

                                    if (mounted) {
                                      setState(() {
                                        _answersCount++;
                                      });
                                    }
                                  },
                                )
                              : ConstrainedBox(
                                  constraints: _kFloatingButtonHeightConstraint,
                                ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      // Use SafeArea to indent the child by the amount
                      // necessary to avoid The Notch on the iPhone X,
                      // or other similar creative physical features of
                      // the display.
                      SafeArea(
                        child: Text(
                          localizations
                              .of(context)
                              .answeredCards(_answersCount),
                          style: app_styles.secondaryText,
                        ),
                      ),
                    ],
                  )
                ],
              ),
      );

  Future<void> _nextCardArrived(ScheduledCardModel scheduledCard) async {
    if (!mounted) {
      return;
    }
    // We call setState because the next card has arrived and we have to
    // display it.
    setState(() {
      // New card arrived, do not show reply buttons.
      _showReplyButtons.value = false;
      _scheduledCard = scheduledCard;
      _card = _deck.value.cards.getItem(scheduledCard.key);
    });

    if (!_learnBeyondHorizon && scheduledCard.repeatAt.isAfter(clock.now())) {
      if (!_atLeastOneCardShown) {
        _learnBeyondHorizon = await showSaveUpdatesDialog(
                context: context,
                changesQuestion: localizations
                    .of(context)
                    .continueLearningQuestion(DateFormat.yMMMd()
                        .add_jm()
                        .format(scheduledCard.repeatAt)),
                noAnswer: localizations.of(context).no,
                yesAnswer: localizations.of(context).yes) ==
            true;
      }
      if (!_learnBeyondHorizon) {
        Navigator.of(context).pop();
      }
    }

    _atLeastOneCardShown = true;
  }
}
