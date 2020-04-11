import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._();

  static AppConfig get instance => _instance;

  AppConfig._() {
    _init();
  }

  // Value initialized from Remote Config, whether enable or disable images
  // feature in the app (uploading images).
  bool get imageFeatureEnabled {
    final value = _remoteConfig?.getValue('images_feature_enabled');
    // For better readability
    // ignore: avoid_bool_literals_in_conditional_expressions
    return value.source == ValueSource.valueRemote ? value.asBool() : true;
  }

  // Value initialized from Remote Config, whether enable or disable sharing
  // decks with other users.
  bool get sharingFeatureEnabled {
    final value = _remoteConfig?.getValue('sharing_feature_enabled');
    // For better readability
    // ignore: avoid_bool_literals_in_conditional_expressions
    return value.source == ValueSource.valueRemote ? value.asBool() : true;
  }

  RemoteConfig _remoteConfig;

  Future<void> _init() async {
    _remoteConfig = await RemoteConfig.instance;
    await _remoteConfig
        .setConfigSettings(RemoteConfigSettings(debugMode: kDebugMode));
    final duration = kDebugMode ? const Duration() : const Duration(hours: 5);
    return _remoteConfig.fetch(expiration: duration);
  }
}
