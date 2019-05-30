import 'dart:async';
import 'dart:math';

import 'package:delern_flutter/flutter/localization.dart' as localization;
import 'package:delern_flutter/l10n/app_localizations.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:flutter/material.dart';

class UserMessages {
  // TODO(ksheremet): Get rid of it
  static Future<void> showError(ScaffoldState Function() scaffoldFinder, e,
      [StackTrace stackTrace]) {
    final errorFuture = error_reporting.report('showError', e, stackTrace);

    // Call a finder only *after* reporting the error, in case it crashes
    // (often because Scaffold.of cannot find Scaffold ancestor widget).
    final scaffoldState = scaffoldFinder();
    final message =
        formUserFriendlyErrorMessage(localization.of(scaffoldState.context), e);
    showMessage(scaffoldState, message);

    return errorFuture;
  }

  // TODO(ksheremet): Add user message for Snackbar and error message for
  // reporting.
  // In navigation drawer 'Contact us' show user message to user and report
  // error.
  static void showMessage(ScaffoldState scaffoldState, String message) =>
      scaffoldState.showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ));

  static String formUserFriendlyErrorMessage(AppLocalizations locale, e) =>
      locale.errorUserMessage +
      e.toString().substring(0, min(e.toString().length, 50));
}
