import 'dart:async';
import 'dart:isolate';

import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/decks_list/decks_list.dart';
import 'package:delern_flutter/views/helpers/sign_in_widget.dart';
import 'package:delern_flutter/views/onboarding/onboarding.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pedantic/pedantic.dart';

class App extends StatelessWidget {
  static final _analyticsNavigatorObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics());

  @override
  Widget build(BuildContext context) {
    var title = 'Delern';
    assert((title = 'Delern DEBUG') != null);
    return MaterialApp(
      // Produce collections of localized values
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        // This list limits what locales Global Localizations delegates above
        // will support. The first element of this list is a fallback locale.
        Locale('en', 'US'),
        Locale('ru', 'RU'),
      ],
      navigatorObservers: [_analyticsNavigatorObserver],
      title: title,
      // SignInWidget must be above Navigator to provide CurrentUserWidget.of().
      builder: (context, child) => Onboarding(
          afterOnboardingBuilder: () =>
              SignInWidget(afterSignInBuilder: () => child)),
      theme: ThemeData(
          scaffoldBackgroundColor: app_styles.kScaffoldBackgroundColor,
          primarySwatch: app_styles.kPrimarySwatch,
          accentColor: app_styles.kAccentColor),
      home: const DecksList(),
    );
  }
}

Future<void> main() async {
  // This is necessary to initialize Flutter method channels so that Crashlytics
  // can call into the native code.
  WidgetsFlutterBinding.ensureInitialized();

  // We report under a different project in dev mode.
  // TODO(dotdoom): https://github.com/FirebaseExtended/flutterfire/pull/105.
  // Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  final debugPrintWithoutCrashlytics = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    Crashlytics.instance.log(message);
    debugPrintWithoutCrashlytics(message, wrapWidth: wrapWidth);
  };

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await error_reporting.report(
      'Isolate ErrorListener',
      errorAndStacktrace.first,
      errorAndStacktrace.last == null
          ? null
          : StackTrace.fromString(errorAndStacktrace.last),
    );
  }).sendPort);

  unawaited(runZoned<Future>(() async {
    unawaited(FirebaseDatabase.instance.setPersistenceEnabled(true));
    unawaited(FirebaseAnalytics().logAppOpen());
    runApp(App());
  }, onError: Crashlytics.instance.recordError));
}
