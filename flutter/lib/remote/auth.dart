import 'dart:async';

import 'package:delern_flutter/models/user.dart';
import 'package:delern_flutter/remote/credential_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:quiver/strings.dart';

/// An abstraction layer on top of FirebaseAuth.
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

  bool _authStateKnown = false;
  bool get authStateKnown => _authStateKnown;

  User _currentUser;
  User get currentUser => _currentUser;

  /// Sign in using a specified provider. If the user is currently signed in
  /// anonymously, try to preserve uid. This will work only if the user hasn't
  /// signed in with this provider before, otherwise throws PlatformException.
  /// For the full list of errors, see both [FirebaseAuth.signInWithCredential]
  /// and FirebaseUser.linkWithCredential methods.
  ///
  /// Some providers may skip through the account picker window if sign in has
  /// already happened (e.g. after a failed account linking). To give user a
  /// choice, we explicitly sign out. If you don't want this behavior, set
  /// [forceAccountPicker] to false.
  ///
  /// NOTE: if the user cancels sign in (e.g. presses "Back" when presented an
  /// account picker), the Future will still complete successfully, but no
  /// changes are done.
  Future<void> signIn(
    String provider, {
    bool forceAccountPicker = true,
  }) async {
    FirebaseUser user;

    if (provider == null) {
      user = await FirebaseAuth.instance.signInAnonymously();
    } else {
      final credential = await credentialProviders[provider]
          .getCredential(forceAccountPicker: forceAccountPicker);

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
      AuthCredential credential;
      for (final provider in credentialProviders.values) {
        if ((credential = await provider.getCredential(silent: true)) != null) {
          break;
        }
      }

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

  void _setCurrentUser(FirebaseUser user) {
    if (user == null || _currentUser?.updateDataSource(user) != true) {
      _currentUser?.dispose();
      _currentUser = user == null ? null : User(user);
    }
    _userChanged.add(_currentUser);
  }

  /// Collect user facing information from providers and fill it into Firebase
  /// if it was not already there.
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
