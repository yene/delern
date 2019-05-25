import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';

set uid(String uid) => FlutterCrashlytics().setUserInfo(uid, '', '');

Future<void> initialize() => FlutterCrashlytics().initialize();

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

  print('Sending error report...');
  final client = FlutterCrashlytics();
  if (extra != null) {
    for (final entry in extra.entries) {
      await client.setInfo(entry.key, entry.value.toString());
    }
  }
  await client.setInfo('source', src);
  return client.reportCrash(error, stackTrace);
}
