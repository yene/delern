import 'package:delern_flutter/flutter/legal.dart';
import 'package:delern_flutter/flutter/localization.dart';
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
  static const _kHeightBetweenWidgets = SizedBox(height: 8);

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

  Widget _buildSignInControls(BuildContext context) => LayoutBuilder(
        builder: (_, viewportConstraints) => SingleChildScrollView(
          child: ConstrainedBox(
            // SingleChildScrollView will shrink-wrap the content, even when
            // there's enough room on the viewport (screen) to provide
            // comfortable spacing between the items in Column.
            // Setting minimum constraints ensures that the column becomes
            // either as big as viewport, or as big as the contents, whichever
            // is biggest. For more information, see:
            // https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html#centering-spacing-or-aligning-fixed-height-content
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kBorderPadding),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                // We put two Column widgets inside one with spaceBetween so
                // that any space unoccupied by the two is in between them.
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: _kBorderPadding),
                        child: Text(
                          context.l.signInWithLabel.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SignInButton(
                          providerId: GoogleAuthProvider.providerId),
                      _kHeightBetweenWidgets,
                      const SignInButton(
                          providerId: FacebookAuthProvider.providerId),
                      _kHeightBetweenWidgets,
                      Text(
                        context.l.splashScreenFeatures,
                        style: app_styles.secondaryText,
                        textAlign: TextAlign.center,
                      ),
                      _kHeightBetweenWidgets,
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: <Widget>[
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: _kBorderPadding),
                            child: Text(
                              context.l.signInScreenOr.toUpperCase(),
                              style: app_styles.secondaryText,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      _kHeightBetweenWidgets,
                      const SignInButton(providerId: null),
                      _kHeightBetweenWidgets,
                      _buildLegalInfo(context),
                      _kHeightBetweenWidgets,
                    ],
                  ),
                ],
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
            TextSpan(text: context.l.legacyAcceptanceLabel),
            _buildLegalUrl(
                context: context,
                url: kPrivacyPolicy,
                text: context.l.privacyPolicySignIn),
            TextSpan(text: context.l.legacyPartsConnector),
            _buildLegalUrl(
                context: context,
                url: kTermsOfService,
                text: context.l.termsOfServiceSignIn),
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
        style: app_styles.secondaryText.copyWith(
          decoration: TextDecoration.underline,
          color: app_styles.kHyperlinkColor,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrl(url, context);
          },
      );
}
