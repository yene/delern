import 'package:delern_flutter/flutter/legal.dart';
import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/url_launcher.dart';
import 'package:delern_flutter/views/sign_in/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A screen with sign in information and buttons.
class SignIn extends StatelessWidget {
  static const routeName = '/signIn';

  const SignIn() : super();

  @override
  Widget build(BuildContext context) => Scaffold(
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

  Widget _buildSignInControls(BuildContext context) => LayoutBuilder(
        builder: (_, viewportConstraints) => SingleChildScrollView(
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
                Text(localizations.of(context).signInWithLabel.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    )),
                const SignInButton(providerId: GoogleAuthProvider.providerId),
                const SignInButton(providerId: FacebookAuthProvider.providerId),
                ...?_getFeatures(context),
                Text(
                  localizations.of(context).doNotNeedFeaturesText,
                  style: app_styles.secondaryText,
                  textAlign: TextAlign.center,
                ),
                const SignInButton(providerId: null),
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
