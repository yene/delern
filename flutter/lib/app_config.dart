class AppConfig {
  static final AppConfig _instance = AppConfig._();

  static AppConfig get instance => _instance;

  AppConfig._();

  // Value initialized from Remote Config, whether enable or disable images
  // feature in the app (uploading images).
  bool imageFeatureEnabled;

  // Value initialized from Remote Config, whether enable or disable sharing
  // decks with other users.
  bool sharingFeatureEnabled;
}
