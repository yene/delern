import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_sentry/flutter_sentry.dart';
import 'package:sentry/sentry.dart';

set uid(String uid) => FlutterSentry.instance.userContext = User(id: uid);

Future<void> report(
  String src,
  error,
  StackTrace stackTrace, {
  Map<String, dynamic> extra,
}) async {
  if (stackTrace == null && error is Error) {
    stackTrace = error.stackTrace;
  }
  stackTrace ??= StackTrace.current;

  debugPrint('Sending error report: $error\n$stackTrace\n---');
  if (extra != null) {
    debugPrint('Extra: $extra');
    // TODO(dotdoom): add extra to event instead of user, when possible.
    FlutterSentry.instance.userContext = User(
      id: FlutterSentry.instance.userContext?.id,
      extras: extra,
    );
  }

  // TODO(dotdoom): include "src" in the report, or get rid of it.
  return FlutterSentry.instance.captureException(
    exception: error,
    stackTrace: stackTrace,
  );
}
