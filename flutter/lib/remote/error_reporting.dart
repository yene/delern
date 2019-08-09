import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

set uid(String uid) => Crashlytics.instance.setUserIdentifier(uid);

Future<void> report(String src, error, StackTrace stackTrace,
    {Map<String, dynamic> extra, bool printErrorInfo = true}) async {
  if (printErrorInfo) {
    debugPrint('/!\\ /!\\ /!\\ Caught error in $src: $error');
  }

  if (stackTrace == null && error is Error) {
    stackTrace = error.stackTrace;
  }
  stackTrace ??= StackTrace.current;

  if (printErrorInfo) {
    debugPrint(
        'Stack trace follows on the next line:\n$stackTrace\n${'-' * 80}');
  }

  debugPrint('Sending error report...');
  if (extra != null) {
    for (final entry in extra.entries) {
      Crashlytics.instance.setString(entry.key, entry.value.toString());
    }
  }

  // We report under a different project in dev mode.
  Crashlytics.instance.enableInDevMode = true;
  return Crashlytics.instance.onError(
      FlutterErrorDetails(exception: error, stack: stackTrace, library: src));
}
