import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

set uid(String uid) => Crashlytics.instance.setUserIdentifier(uid);

Future<void> report(String src, error, StackTrace stackTrace,
    {Map<String, dynamic> extra}) async {
  if (stackTrace == null && error is Error) {
    stackTrace = error.stackTrace;
  }
  stackTrace ??= StackTrace.current;

  debugPrint('Sending error report...');
  if (extra != null) {
    for (final entry in extra.entries) {
      debugPrint('[extra] ${entry.key}: ${entry.value}');
      Crashlytics.instance.setString(entry.key, entry.value.toString());
    }
  }

  return Crashlytics.instance.recordError(error, stackTrace, context: src);
}
