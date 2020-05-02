import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

class EmptyListMessageWidget extends StatelessWidget {
  final String _displayText;

  const EmptyListMessageWidget(this._displayText);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          _displayText,
          style: app_styles.secondaryText,
        ),
      );
}
