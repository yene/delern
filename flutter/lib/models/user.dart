import 'package:delern_flutter/models/base/data_writer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiver/strings.dart';

enum SignInProvider {
  google,
}

class User extends DataWriter {
  final FirebaseUser _dataSource;

  User(this._dataSource)
      : assert(_dataSource != null),
        super(uid: _dataSource.uid);

  /// Unique ID of the user used in Firebase Database and across the app.
  String get uid => _dataSource.uid;

  /// Display name. Can be null, e.g. for anonymous user.
  String get displayName =>
      isBlank(_dataSource.displayName) ? null : _dataSource.displayName;

  /// Photo URL. Can be null.
  String get photoUrl =>
      isBlank(_dataSource.photoUrl) ? null : _dataSource.photoUrl;

  /// Email. Can be null.
  String get email => isBlank(_dataSource.email) ? null : _dataSource.email;

  /// All providers (aka "linked accounts") for the current user. Empty for
  /// anonymously signed in.
  Iterable<SignInProvider> get providers => _dataSource.providerData
      .map((p) => _parseSignInProvider(p.providerId))
      .where((p) => p != null);

  bool get isAnonymous => _dataSource.isAnonymous;

  static SignInProvider _parseSignInProvider(String providerId) {
    switch (providerId) {
      case GoogleAuthProvider.providerId:
        return SignInProvider.google;
      // TODO(dotdoom): add more providers here #944.
    }
    // For anonymous users, providerId == 'firebase'.
    return null;
  }
}
