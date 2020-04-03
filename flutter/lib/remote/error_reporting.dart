import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_sentry/flutter_sentry.dart';
import 'package:sentry/sentry.dart';

set uid(String uid) => FlutterSentry.instance.userContext = User(id: uid);

// TODO(dotdoom): get rid of "src", make "stackTrace" optional.
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

  debugPrint('Sending error report from $src: $error\n$stackTrace\n---');
  if (extra == null) {
    extra = {'src': src};
  } else {
    debugPrint('Extra: $extra');
    extra = Map<String, dynamic>.from(extra)..['src'] = src;
  }

  return FlutterSentry.instance.captureException(
    exception: error,
    stackTrace: stackTrace,
    extra: extra,
  );
}
