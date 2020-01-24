import 'dart:async';

import 'package:flutter/material.dart';

/// Call for [showDialog] with a [changesQuestion] and [yesAnswer] and
/// [noAnswer] capitalized text buttons, returning `true` for "yes" and `false`
/// for "no". The dialog is not otherwise dismissable.
///
/// The order of "yes" and "no" buttons depends on [defaultIsYes]; when set to
/// `true`, "yes" button is located at user's finger (corner of the widget).
/// Otherwise, the buttons are swapped.
Future<bool> showSaveUpdatesDialog({
  @required BuildContext context,
  @required String changesQuestion,
  @required String yesAnswer,
  @required String noAnswer,
  bool defaultIsYes = true,
}) {
  final actions = <Widget>[
    FlatButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(noAnswer.toUpperCase())),
    FlatButton(
      onPressed: () => Navigator.of(context).pop(true),
      child: Text(yesAnswer.toUpperCase()),
    )
  ];
  return showDialog<bool>(
    context: context,
    // The user must tap a button!
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      // The user must tap a button!
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text(changesQuestion),
        actions: defaultIsYes ? actions : actions.reversed.toList(),
      ),
    ),
  );
}
