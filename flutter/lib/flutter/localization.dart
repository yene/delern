import 'dart:async';

import 'package:delern_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// https://flutter.io/tutorials/internationalization/
AppLocalizations of(BuildContext context) =>
    Localizations.of<AppLocalizations>(context, AppLocalizations);

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(
      locale.countryCode.isEmpty ? locale.languageCode : locale.toString());

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
