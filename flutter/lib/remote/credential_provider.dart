import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

// There might be more methods coming soon (e.g. verifyEmail and signOut).
// ignore: one_member_abstracts
abstract class CredentialProvider {
  /// Get AuthCredential from user or provider-specific credential cache.
  ///
  /// When [silent] is set, do not interact with the user and only obtain
  /// previously cached credential, or `null` when there's no valid credential.
  /// When [forceAccountPicker] is set, always provide account selection dialog,
  /// perhaps by clearing credential cache (also known as signing out).
  ///
  /// The caller guarantees that [silent] and [forceAccountPicker] are not set
  /// to `true` at the same time.
  ///
  /// The return Future should resolve to `null` if the user has cancelled login
  /// dialog, or an error if an unexpected condition was met (e.g. application
  /// misconfiguration, network connection issues).
  Future<AuthCredential> getCredential({
    bool silent = false,
    bool forceAccountPicker = false,
  });
}

// The order in this map defines silent Sign In probe order. First wins.
final credentialProviders = <String, CredentialProvider>{
  GoogleAuthProvider.providerId: _GoogleCredentialProvider(),
  FacebookAuthProvider.providerId: _FacebookCredentialProvider(),
  // TODO(dotdoom): handle other providers here (ex.: Twitter) #944.
};

class _GoogleCredentialProvider implements CredentialProvider {
  static final _googleSignIn = GoogleSignIn();

  @override
  Future<AuthCredential> getCredential({
    bool silent = false,
    bool forceAccountPicker = false,
  }) async {
    assert(!(silent && forceAccountPicker),
        'Silent Sign In is meaningless if Sign Out is forced first');
    if (forceAccountPicker) {
      await _googleSignIn.signOut();
    }

    final account = await (silent
        ? _googleSignIn.signInSilently()
        : _googleSignIn.signIn());
    if (account == null) {
      // signInSilently() will suppress any errors and return null, and signIn()
      // will also return null if the user has cancelled authentication.
      return null;
    }
    final auth = await account.authentication;
    // NOTE: `auth` may contain an access token that is not valid at this point
    //       anymore, or will expire in a few seconds. There is no guarantee
    //       that the token is up to date. If this happens, further use of the
    //       token (e.g. `signInWithCredential`) will fail. To recover from
    //       this, we can force token re-generation when signIn fails, by using
    //       `await account.clearAuthCache()`. Note that `getCredential()` call
    //       below will never fail as it merely copies tokens into a different
    //       structure without validation.
    //       Another solution is to always call `clearAuthCache()`, but what are
    //       the side effects of it?
    return GoogleAuthProvider.getCredential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
  }
}

class _FacebookCredentialProvider implements CredentialProvider {
  static final _facebookSignIn = FacebookLogin();

  @override
  Future<AuthCredential> getCredential({
    bool silent = false,
    bool forceAccountPicker = false,
  }) async {
    if (forceAccountPicker) {
      await _facebookSignIn.logOut();
    }

    FacebookAccessToken accessToken;

    if (silent) {
      accessToken = await _facebookSignIn.currentAccessToken;
    } else {
      final result = await _facebookSignIn.logIn(['public_profile', 'email']);
      if (result.status == FacebookLoginStatus.loggedIn) {
        accessToken = result.accessToken;
      }
    }

    if (accessToken != null && accessToken.isValid()) {
      return FacebookAuthProvider.getCredential(accessToken: accessToken.token);
    }
    return null;
  }
}
