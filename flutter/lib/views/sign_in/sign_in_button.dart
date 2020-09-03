import 'package:delern_flutter/remote/auth.dart';
import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/user_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

@immutable
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: SignInButtonContainer(
          color: app_styles.kGoogleSignInButtonColor,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      context.l.signInWithGoogle.toUpperCase(),
                      style: app_styles.signInTextButton,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    heightFactor: 0.85,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset('images/google_sign_in.png'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

@immutable
class FacebookSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FacebookSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: SignInButtonContainer(
          color: app_styles.kFacebookBlueColor,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      context.l.signInWithFacebook.toUpperCase(),
                      style: app_styles.signInTextButton,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1.5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'images/facebook_sign_in.webp',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class AnonymousSighInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AnonymousSighInButton({this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onPressed,
        child: SignInButtonContainer(
          color: app_styles.kPrimarySwatch,
          child: Center(
            child: Text(
              context.l.continueAnonymously.toUpperCase(),
              style: app_styles.signInTextButton,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
}

@immutable
class SignInButtonContainer extends StatelessWidget {
  static const _buttonHeight = 48.0;

  final Widget child;
  final Color color;

  const SignInButtonContainer({
    @required this.child,
    @required this.color,
  })  : assert(child != null),
        assert(color != null);

  @override
  Widget build(BuildContext context) => Padding(
      // Padding around the button to avoid clashing it into other widgets
      // when short on space.
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        height: _buttonHeight,
        child: Container(
            //elevation: _buttonElevation,
            //onPressed: onPressed,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: child),
      ));
}

Future<void> signInWithProvider({
  @required BuildContext context,
  @required String provider,
  bool forceAccountPicker = true,
}) async {
  try {
    await Auth.instance.signIn(
      provider,
      forceAccountPicker: forceAccountPicker,
    );
  } on PlatformException catch (e, stackTrace) {
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
            changesQuestion: context.l.signInCredentialAlreadyInUseWarning,
            yesAnswer: context.l.navigationDrawerSignIn,
            noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
        if (signIn) {
          // Sign out of Firebase but retain the account that has been picked
          // by user.
          await Auth.instance.signOut();
          return _signInWithProvider(
              context: context, provider: provider, forceAccountPicker: false);
        }
        break;

      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        // Trying to sign in with a different provider but the same email.
        // Can't showDialog because we don't have Navigator before sign in.
        UserMessages.showMessage(Scaffold.of(context),
            context.l.signInAccountExistWithDifferentCredentialWarning);
        break;

      default:
        UserMessages.showAndReportError(
          () => Scaffold.of(context),
          e,
          stackTrace: stackTrace,
        );
    }
  }
}

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
  } on PlatformException catch (e, stackTrace) {
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
            changesQuestion: context.l.signInCredentialAlreadyInUseWarning,
            yesAnswer: context.l.navigationDrawerSignIn,
            noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
        if (signIn) {
          // Sign out of Firebase but retain the account that has been picked
          // by user.
          await Auth.instance.signOut();
          return _signInWithProvider(
              context: context, provider: provider, forceAccountPicker: false);
        }
        break;

      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        // Trying to sign in with a different provider but the same email.
        // Can't showDialog because we don't have Navigator before sign in.
        UserMessages.showMessage(Scaffold.of(context),
            context.l.signInAccountExistWithDifferentCredentialWarning);
        break;

      default:
        UserMessages.showAndReportError(
          () => Scaffold.of(context),
          e,
          stackTrace: stackTrace,
        );
    }
  }
}
