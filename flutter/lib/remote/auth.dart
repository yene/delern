import 'dart:async';

import 'package:delern_flutter/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quiver/strings.dart';

class Auth {
  static final instance = Auth._();
  Auth._() {
    // Even though this will be evaluated lazily, the initial trigger is
    // guaranteed by Firebase (per documentation).
    FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) async {
      _authStateKnown = true;
      _setCurrentUser(firebaseUser);
    });
  }

  final _userChanged = StreamController<User>.broadcast();
  Stream<User> get onUserChanged => _userChanged.stream;

  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _authStateKnown = false;
  bool get authStateKnown => _authStateKnown;

  User _currentUser;
  User get currentUser => _currentUser;

  /// Sign in using a specified provider. If the user is currently signed in
  /// anonymously, try to preserve uid. This will work only if the user hasn't
  /// signed in with this provider before, otherwise throws PlatformException.
  ///
  /// Some providers may skip through the account picker window if sign in has
  /// already happened (e.g. after a failed account linking). To give user a
  /// choice, we explicitly sign out. If you don't want this behavior, set
  /// [forceAccountPicker] to false.
  ///
  /// NOTE: if the user cancels sign in (e.g. presses "Back" when presented an
  /// account picker), the Future will still complete successfully, but no
  /// changes are done.
  Future<void> signIn(SignInProvider provider,
      {bool forceAccountPicker = true}) async {
    FirebaseUser user;

    if (provider == null) {
      user = await FirebaseAuth.instance.signInAnonymously();
    } else {
      AuthCredential credential;
      switch (provider) {
        case SignInProvider.google:
          credential =
              await _getGoogleCredential(signOutFirst: forceAccountPicker);
          break;
        // TODO(dotdoom): handle other providers here (ex.: Facebook) #944.
      }

      // Credential is unset, usually cancelled by user.
      if (credential == null) {
        return;
      }

      user = await ((_currentUser == null)
          ? FirebaseAuth.instance.signInWithCredential(credential)
          : FirebaseAuth.instance.linkWithCredential(credential));

      // After `await`, `_currentUser` is set by `onAuthStateChanged` callback.
      if (await _updateProfileFromProviders(user)) {
        _setCurrentUser(await FirebaseAuth.instance.currentUser());
      }
    }
  }

  /// If user is already signed in, do nothing. If we have existing credential
  /// (e.g. user was signed in at the previous app run), use that credential to
  /// sign in without asking the user.
  Future<void> signInSilently() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser == null) {
      // TODO(dotdoom): chain other _getXXXCredential(silent: true) here #944.
      final credential = await _getGoogleCredential(silent: true);

      if (credential != null) {
        firebaseUser =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }
    }

    // After `await`, `_currentUser` is set by `onAuthStateChanged` callback.
    if (firebaseUser != null) {
      if (await _updateProfileFromProviders(firebaseUser)) {
        _setCurrentUser(await FirebaseAuth.instance.currentUser());
      }
    }
  }

  /// Sign out of Firebase, but without signing out of linked providers.
  Future<void> signOut() => FirebaseAuth.instance.signOut();

  Future<AuthCredential> _getGoogleCredential(
      {silent = false, signOutFirst = false}) async {
    assert(!(silent && signOutFirst),
        'Silent Sign In is meaningless if Sign Out is forced first');
    if (signOutFirst) {
      await _googleSignIn.signOut();
    }

    final account = await (silent
        ? _googleSignIn.signInSilently()
        : _googleSignIn.signIn());
    if (account == null) {
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

  void _setCurrentUser(FirebaseUser user) {
    if (user == null || _currentUser?.updateDataSource(user) != true) {
      _currentUser?.dispose();
      _currentUser = user == null ? null : User(user);
    }
    _userChanged.add(_currentUser);
  }

  static Future<bool> _updateProfileFromProviders(FirebaseUser user) async {
    final update = UserUpdateInfo();

    var anyUpdates = false;
    for (final providerData in user.providerData) {
      if (isBlank(user.displayName) && !isBlank(providerData.displayName)) {
        update.displayName = providerData.displayName;
        debugPrint(
            'Updating displayName from provider ${providerData.providerId}');
        anyUpdates = true;
      }
      if (isBlank(user.photoUrl) && !isBlank(providerData.photoUrl)) {
        update.photoUrl = providerData.photoUrl;
        debugPrint(
            'Updating photoUrl from provider ${providerData.providerId}');
        anyUpdates = true;
      }
    }
    if (anyUpdates) {
      await user.updateProfile(update);
      // reload() does not change existing instance. The caller will have to get
      // currentUser() again: https://github.com/flutter/plugins/pull/533.
      await user.reload();
    }
    return anyUpdates;
  }
}
