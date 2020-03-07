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
  static const _kBorderPadding = 15.0;
  static const _kMinBetweenWidgetsBox = SizedBox(height: 8);

  const SignIn() : super();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: app_styles.signInBackgroundColor,
        body: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) =>
                (orientation == Orientation.portrait)
                    ? _buildPortraitSignInScreen(context)
                    : _buildLandscapeSignInScreen(context),
          ),
        ),
      );

  Widget _buildLogoPicture(BuildContext context, double width) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 30,
                horizontal: _kBorderPadding,
              ),
              child: Image.asset(
                'images/delern_with_logo.png',
                width: width,
              ),
            ),
          ],
        ),
      );

  Widget _buildSignInControls(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _kBorderPadding),
        child: LayoutBuilder(
          builder: (_, viewportConstraints) => SingleChildScrollView(
            child: ConstrainedBox(
              // SingleChildScrollView will shrink-wrap the content, even when
              // there's enough room on the viewport (screen) to provide
              // comfortable spacing between the items in Column.
              // It also ensures that the column becomes either as big as
              // viewport, or as big as the contents, whichever is biggest.
              // See also: https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html#centering-spacing-or-aligning-fixed-height-content
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: _kBorderPadding),
                            child: Text(
                                localizations
                                    .of(context)
                                    .signInWithLabel
                                    .toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                          const SignInButton(
                              providerId: GoogleAuthProvider.providerId),
                          _kMinBetweenWidgetsBox,
                          const SignInButton(
                              providerId: FacebookAuthProvider.providerId),
                          _kMinBetweenWidgetsBox,
                          Text(
                            localizations.of(context).splashScreenFeatures,
                            style: app_styles.secondaryText,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    _kMinBetweenWidgetsBox,
                    Row(
                      children: <Widget>[
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: _kBorderPadding),
                          child: Text(
                            localizations.of(context).or.toUpperCase(),
                            style: app_styles.secondaryText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    _kMinBetweenWidgetsBox,
                    const SignInButton(providerId: null),
                    _kMinBetweenWidgetsBox,
                    _buildLegalInfo(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildPortraitSignInScreen(BuildContext context) => Column(
        children: <Widget>[
          _buildLogoPicture(context, MediaQuery.of(context).size.width / 2),
          const Divider(),
          Expanded(child: _buildSignInControls(context)),
        ],
      );

  Widget _buildLandscapeSignInScreen(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildLogoPicture(context, MediaQuery.of(context).size.width / 3),
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
