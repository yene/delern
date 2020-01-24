import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';

class SignInButton extends StatelessWidget {
  final String providerId;

  static const _buttonHeight = 48.0;

  const SignInButton({
    @required this.providerId,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (providerId) {
      case GoogleAuthProvider.providerId:
        return _buildButton(context,
            color: Colors.white,
            providerIconAsset: 'images/google_sign_in.png',
            buttonText: Text(
              localizations.of(context).signInWithGoogle,
              style: app_styles.primaryText,
              overflow: TextOverflow.ellipsis,
            ));
      case FacebookAuthProvider.providerId:
        return _buildButton(context,
            color: app_styles.kFacebookBlueColor,
            providerIconAsset: 'images/facebook_sign_in.png',
            buttonText: Text(
              localizations.of(context).signInWithFacebook,
              style: app_styles.primaryText
                  .merge(const TextStyle(color: Colors.white)),
              overflow: TextOverflow.ellipsis,
            ));
      default:
        return RaisedButton(
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
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
    }
  }

  Widget _buildButton(
    BuildContext context, {
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: buttonText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

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
              Scaffold.of(context),
              localizations
                  .of(context)
                  .signInAccountExistWithDifferentCredentialWarning);
          break;

        default:
          unawaited(UserMessages.showError(() => Scaffold.of(context), e));
      }
    }
  }
}
