import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/views/helpers/slow_operation_widget.dart';
import 'package:flutter/material.dart';

class CardAnswerButtonsWidget extends StatelessWidget {
  final User user;
  final ScheduledCardModel scheduledCard;
  final void Function(bool knows) onAnswer;

  const CardAnswerButtonsWidget({
    @required this.user,
    @required this.scheduledCard,
    @required this.onAnswer,
    Key key,
  })  : assert(user != null),
        assert(scheduledCard != null),
        assert(onAnswer != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => SlowOperationWidget((cb) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            // heroTag - https://stackoverflow.com/questions/46509553/
            tooltip: context.l.doNotKnowCardTooltip,
            heroTag: 'dontknow',
            backgroundColor: Colors.red,
            onPressed: cb(() => _answerCard(
                  context: context,
                  knows: false,
                )),
            child: const Icon(Icons.clear),
          ),
          FloatingActionButton(
            tooltip: context.l.knowCardTooltip,
            heroTag: 'know',
            backgroundColor: Colors.green,
            onPressed: cb(() => _answerCard(
                  context: context,
                  knows: true,
                )),
            child: const Icon(Icons.check),
          ),
        ],
      ));

  Future<void> _answerCard({
    // TODO(dotdoom): do not pass context in stateless widget.
    @required BuildContext context,
    @required bool knows,
  }) async {
    try {
      await user.learnCard(
        unansweredScheduledCard: scheduledCard,
        knows: knows,
      );
    } catch (e, stackTrace) {
      UserMessages.showAndReportError(
        () => Scaffold.of(context),
        e,
        stackTrace: stackTrace,
      );
      return;
    }

    onAnswer(knows);
  }
}
