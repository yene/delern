import 'dart:async';

import 'package:delern_flutter/flutter/device_info.dart';
import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/fcm.dart';
import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

class SignInWidget extends StatefulWidget {
  final Widget Function() afterSignInBuilder;

  const SignInWidget({@required this.afterSignInBuilder})
      : assert(afterSignInBuilder != null);

  @override
  State<StatefulWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  static const _itemPadding =
      Padding(padding: EdgeInsets.symmetric(vertical: 10));
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
                : loginProviders.first.toString()));

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

  Widget _buildFeatureText(String text) => ListTile(
      leading: const Icon(Icons.check_circle),
      title: Text(text, style: app_styles.primaryText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8));

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      return CurrentUserWidget(
          user: _currentUser, child: widget.afterSignInBuilder());
    }
    if (!Auth.instance.authStateKnown) {
      return ProgressIndicatorWidget();
    }

    return Scaffold(
      backgroundColor: app_styles.signInBackgroundColor,
      body: OrientationBuilder(
          builder: (context, orientation) =>
              (orientation == Orientation.portrait)
                  ? _buildPortraitSignInScreen(context)
                  : _buildLandscapeSignInScreen(context)),
    );
  }

  List<Widget> _getFeatures(BuildContext context) => localizations
      .of(context)
      .splashScreenFeatures
      .split('\n')
      .map(_buildFeatureText)
      .toList();

  Widget _buildGoogleSignInButton(Orientation orientation) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: RaisedButton(
            color: Colors.white,
            onPressed: () => Auth.instance.signIn(SignInProvider.google),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(
                      Orientation.portrait == orientation ? 10.0 : 5.0),
                  child: Image.asset(
                    'images/google_sign_in.png',
                    height: 35,
                    width: 35,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      localizations.of(context).signInWithGoogle,
                      style: app_styles.primaryText,
                    )),
              ],
            )),
      );

  Widget _buildLogoPicture() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/ic_launcher.png',
            ),
            Text(
              localizations.of(context).appLogoName,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );

  Widget _buildAnonymousSignInButton(Orientation orientation) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: RaisedButton(
            color: Colors.white,
            onPressed: () => Auth.instance.signIn(null),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical:
                          Orientation.portrait == orientation ? 15.0 : 10.0),
                  child: Text(
                    localizations.of(context).continueAnonymously,
                    style: app_styles.primaryText,
                  ),
                ),
              ],
            )),
      );

  Widget _buildDoNotNeedFeaturesText() => Text(
        localizations.of(context).doNotNeedFeaturesText,
        style: app_styles.secondaryText,
      );

  Widget _buildLandscapeSignInScreen(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLogoPicture(),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                      _itemPadding,
                    ] +
                    _getFeatures(context) +
                    [
                      _buildGoogleSignInButton(Orientation.landscape),
                      _itemPadding,
                      _buildDoNotNeedFeaturesText(),
                      _itemPadding,
                      _buildAnonymousSignInButton(Orientation.landscape),
                      _itemPadding,
                    ],
              ),
            ),
          )
        ],
      );

  // TODO(ksheremet): Make widget Scrollable with more sign in options
  Widget _buildPortraitSignInScreen(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
              Expanded(child: Center(child: _buildLogoPicture())),
              _itemPadding,
              _buildGoogleSignInButton(Orientation.portrait),
              _itemPadding,
            ] +
            _getFeatures(context) +
            [
              _itemPadding,
              _buildDoNotNeedFeaturesText(),
              _itemPadding,
              _buildAnonymousSignInButton(Orientation.portrait),
              _itemPadding
            ],
      );
}

class CurrentUserWidget extends InheritedWidget {
  final User user;

  static CurrentUserWidget of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(CurrentUserWidget);

  const CurrentUserWidget({@required this.user, Key key, Widget child})
      : assert(user != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(CurrentUserWidget oldWidget) =>
      user != oldWidget.user;
}
