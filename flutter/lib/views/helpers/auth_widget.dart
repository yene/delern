import 'dart:async';

import 'package:delern_flutter/flutter/device_info.dart';
import 'package:delern_flutter/models/fcm.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/sign_in_widget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

/// A widget handling application-wide user authentication and anything
/// associated with it (FCM, Sign In etc). Renders either as a [SignInWidget],
/// or [CurrentUserWidget] wrapped around [afterSignInBuilder].
class AuthWidget extends StatefulWidget {
  final Widget Function() afterSignInBuilder;

  const AuthWidget({@required this.afterSignInBuilder})
      : assert(afterSignInBuilder != null);

  @override
  State<StatefulWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  User _currentUser = Auth.instance.currentUser;

  StreamSubscription _fcmSubscription, _userChangedSubscription;

  @override
  void initState() {
    super.initState();

    _fcmSubscription = FirebaseMessaging().onTokenRefresh.listen((token) async {
      if (token == null) {
        return;
      }

      final fcm = (FCMBuilder()
            ..language = Localizations.localeOf(context).toString()
            ..name = (await DeviceInfo.getDeviceInfo()).userFriendlyName
            ..key = token)
          .build();

      debugPrint('Registering for FCM as ${fcm.name} in ${fcm.language}');
      unawaited(_currentUser.addFCM(fcm: fcm));
    });

    _userChangedSubscription =
        Auth.instance.onUserChanged.listen((newUser) async {
      setState(() {
        _currentUser = newUser;
      });

      if (_currentUser != null) {
        error_reporting.uid = _currentUser.uid;

        unawaited(FirebaseAnalytics().setUserId(_currentUser.uid));
        final loginProviders = _currentUser.providers;
        unawaited(FirebaseAnalytics().logLogin(
            loginMethod: loginProviders.isEmpty
                ? 'anonymous'
                : loginProviders.join(',')));

        unawaited(_currentUser.setLastOnlineAt());

        // TODO(dotdoom): register onMessage to show a snack bar with
        //                notification when the app is in foreground.
        // Must be called after each login to obtain a FirebaseMessaging token.
        FirebaseMessaging().configure();
      }
    });

    if (!Auth.instance.authStateKnown) {
      debugPrint('Auth state unknown, trying to sign in silently...');
      Auth.instance.signInSilently();
    }
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    _userChangedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      return CurrentUserWidget(_currentUser,
          child: widget.afterSignInBuilder());
    }
    if (!Auth.instance.authStateKnown) {
      return ProgressIndicatorWidget();
    }

    return SignInWidget();
  }
}

class CurrentUserWidget extends InheritedWidget {
  final User user;

  static CurrentUserWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CurrentUserWidget>();

  const CurrentUserWidget(this.user, {Key key, Widget child})
      : assert(user != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(CurrentUserWidget oldWidget) =>
      user != oldWidget.user;
}
