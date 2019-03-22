import 'dart:async';

import 'package:flutter/material.dart';

Future<bool> showSaveUpdatesDialog(
        {@required BuildContext context,
        @required String changesQuestion,
        @required String yesAnswer,
        @required String noAnswer}) =>
    showDialog<bool>(
      context: context,
      // user must tap button!
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: Text(changesQuestion),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(noAnswer.toUpperCase())),
              FlatButton(
                child: Text(yesAnswer.toUpperCase()),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
          ),
    );
