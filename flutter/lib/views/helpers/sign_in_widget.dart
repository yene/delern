import 'dart:async';

import 'package:delern_flutter/flutter/legal.dart';
import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/url_launcher.dart';
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

/// A screen with sign in information and buttons.
// TODO(dotdoom): move into views/sign_in/ and remove "Widget" suffix.
@immutable
class SignInWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: app_styles.signInBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: OrientationBuilder(
              builder: (context, orientation) =>
                  (orientation == Orientation.portrait)
                      ? _buildPortraitSignInScreen(context)
                      : _buildLandscapeSignInScreen(context),
            ),
          ),
        ),
      );

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _buttonHeight = 48.0;

  Future<void> _signInWithProvider({
    @required BuildContext context,
    @required String provider,
    bool forceAccountPicker = true,
  }) async {
    try {
      await Auth.instance.signIn(
        provider,
        forceAccountPicker: forceAccountPicker,
      );
      // When launched from within a Navigator (e.g. "Sign In" when currently an
      // anonymous user), pop now.
      // When AuthWidget builds, it will instead listen to userChanged event and
      // rebuild immediately once the user is logged in, replacing this widget
      // with something else.
      Navigator.of(context, nullOk: true)?.pop();
    } on PlatformException catch (e, stackTrace) {
      unawaited(error_reporting.report('signInWithProvider', e, stackTrace));

      // Cover only those scenarios where we can recover or an additional action
      // from user can be helpful.
      switch (e.code) {
        case 'ERROR_EMAIL_ALREADY_IN_USE':
        // Already signed in (as anonymous, normally) and trying to link with
        // account that already exists. And on top of that, using a different
        // provider than the one used for initial account registration.
        case 'ERROR_CREDENTIAL_ALREADY_IN_USE':
          // Already signed in (as anonymous, normally) and trying to link with
          // account that already exists.

          // TODO(ksheremet): Merge data
          final signIn = await showSaveUpdatesDialog(
              context: context,
              changesQuestion:
                  localizations.of(context).signInCredentialAlreadyInUseWarning,
              yesAnswer: localizations.of(context).navigationDrawerSignIn,
              noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
          if (signIn) {
            // Sign out of Firebase but retain the account that has been picked
            // by user.
            await Auth.instance.signOut();
            return _signInWithProvider(
                context: context,
                provider: provider,
                forceAccountPicker: false);
          }
          break;

        case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
          // Trying to sign in with a different provider but the same email.
          // Can't showDialog because we don't have Navigator before sign in.
          UserMessages.showMessage(
              _scaffoldKey.currentState,
              localizations
                  .of(context)
                  .signInAccountExistWithDifferentCredentialWarning);
          break;

        default:
          unawaited(UserMessages.showError(() => _scaffoldKey.currentState, e));
      }
    }
  }

  Widget _buildFeatureText(String text) => Row(
        children: [
          Icon(Icons.check_circle),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: app_styles.primaryText)),
        ],
      );

  List<Widget> _getFeatures(BuildContext context) => localizations
      .of(context)
      .splashScreenFeatures
      .split('\n')
      .map(_buildFeatureText)
      .toList();

  Widget _buildSignInButton(
    BuildContext context, {
    @required String providerId,
    @required Color color,
    @required String providerIconAsset,
    @required Text buttonText,
  }) =>
      Padding(
        // Padding around the button to avoid clashing it into other widgets
        // when short on space.
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: SizedBox(
          height: _buttonHeight,
          child: RaisedButton(
            onPressed: () =>
                _signInWithProvider(context: context, provider: providerId),
            color: color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(providerIconAsset),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: buttonText,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildGoogleSignInButton(BuildContext context) =>
      _buildSignInButton(context,
          providerId: GoogleAuthProvider.providerId,
          color: Colors.white,
          providerIconAsset: 'images/google_sign_in.png',
          buttonText: Text(
            localizations.of(context).signInWithGoogle,
            style: app_styles.primaryText,
          ));

  Widget _buildFacebookSignInButton(BuildContext context) =>
      _buildSignInButton(context,
          providerId: FacebookAuthProvider.providerId,
          color: app_styles.kFacebookBlueColor,
          providerIconAsset: 'images/facebook_sign_in.png',
          buttonText: Text(
            localizations.of(context).signInWithFacebook,
            style: app_styles.primaryText
                .merge(const TextStyle(color: Colors.white)),
          ));

  Widget _buildLogoPicture(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('images/ic_launcher.png'),
              Text(
                localizations.of(context).appLogoName,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );

  Widget _buildAnonymousSignInButton(BuildContext context) => RaisedButton(
        color: Colors.white,
        onPressed: () => Auth.instance.currentUser == null
            ? _signInWithProvider(context: context, provider: null)
            : Navigator.of(context).pop(),
        child: SizedBox(
          height: _buttonHeight,
          child: Center(
            child: Text(
              localizations.of(context).continueAnonymously,
              style: app_styles.primaryText,
            ),
          ),
        ),
      );

  Widget _buildSignInControls(BuildContext context) => LayoutBuilder(
        builder: (_, viewportConstraints) => SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            // SingleChildScrollView will shrink-wrap the content, even when
            // there's enough room on the viewport (screen) to provide
            // comfortable spacing between the items in Column. We set minimum
            // height based on viewport size. See also:
            // https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html#centering-spacing-or-aligning-fixed-height-content
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildGoogleSignInButton(context),
                _buildFacebookSignInButton(context),
                ...?_getFeatures(context),
                Text(
                  localizations.of(context).doNotNeedFeaturesText,
                  style: app_styles.secondaryText,
                  textAlign: TextAlign.center,
                ),
                _buildAnonymousSignInButton(context),
                _buildLegalInfo(context),
              ],
            ),
          ),
        ),
      );

  Widget _buildPortraitSignInScreen(BuildContext context) => Column(
        children: <Widget>[
          _buildLogoPicture(context),
          Expanded(child: _buildSignInControls(context)),
        ],
      );

  Widget _buildLandscapeSignInScreen(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildLogoPicture(context),
          Expanded(child: _buildSignInControls(context)),
        ],
      );

  Widget _buildLegalInfo(BuildContext context) => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: app_styles.secondaryText,
          children: <TextSpan>[
            TextSpan(text: localizations.of(context).legacyAcceptanceLabel),
            _buildLegalUrl(
                context: context,
                url: kPrivacyPolicy,
                text: localizations.of(context).privacyPolicySignIn),
            TextSpan(text: localizations.of(context).legacyPartsConnector),
            _buildLegalUrl(
                context: context,
                url: kTermsOfService,
                text: localizations.of(context).termsOfServiceSignIn),
          ],
        ),
      );

  TextSpan _buildLegalUrl({
    @required BuildContext context,
    @required String url,
    @required String text,
  }) =>
      TextSpan(
        text: text,
        style: app_styles.secondaryText
            .copyWith(decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrl(url, context);
          },
      );
}
