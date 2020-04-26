import 'package:delern_flutter/flutter/localization.dart';
import 'package:flutter/material.dart';

class CardAnswerButtonsWidget extends StatelessWidget {
  final void Function(bool knows) onAnswer;
  final _answered = ValueNotifier<bool>(false);

  CardAnswerButtonsWidget({
    @required this.onAnswer,
    Key key,
  })  : assert(onAnswer != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: _answered,
        builder: (context, answered, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              tooltip: context.l.doNotKnowCardTooltip,
              // https://stackoverflow.com/questions/46509553/
              heroTag: 'dontknow',
              backgroundColor: Colors.red,
              onPressed: answered
                  ? null
                  : () {
                      _answered.value = true;
                      onAnswer(false);
                    },
              child: const Icon(Icons.clear),
            ),
            FloatingActionButton(
              tooltip: context.l.knowCardTooltip,
              heroTag: 'know',
              backgroundColor: Colors.green,
              onPressed: answered
                  ? null
                  : () {
                      _answered.value = true;
                      onAnswer(true);
                    },
              child: const Icon(Icons.check),
            ),
          ],
        ),
      );
}
