import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/deck_model.dart';
import 'package:flutter/material.dart';

enum Gender {
  masculine,
  feminine,
  neuter,
  noGender,
}

List<Color> specifyCardBackgroundColors(DeckType deckType, String text) {
  if (deckType == DeckType.basic) {
    return app_styles.cardBackgroundColors[Gender.noGender];
  }
  var textGender = Gender.noGender;
  text = text.toLowerCase();
  if (deckType == DeckType.swiss) {
    textGender = _swissCardGender(text);
  } else {
    textGender = _germanCardGender(text);
  }
  return app_styles.cardBackgroundColors[textGender];
}

LinearGradient specifyCardBackgroundGradient(DeckType deckType, String text) {
  if (deckType == DeckType.basic) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: app_styles.cardBackgroundColors[Gender.noGender],
    );
  }
  var textGender = Gender.noGender;
  text = text.toLowerCase();
  if (deckType == DeckType.swiss) {
    textGender = _swissCardGender(text);
  } else {
    textGender = _germanCardGender(text);
  }
  return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: app_styles.cardBackgroundColors[textGender]);
}

LinearGradient getEditCardGradientFromGender(Gender gender) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: app_styles.cardBackgroundColors[gender]);

Gender _swissCardGender(String text) {
  if (text.startsWith('de ') || text.startsWith('en ')) {
    return Gender.masculine;
  }
  if (text.startsWith('d ') || text.startsWith('e ')) {
    return Gender.feminine;
  }
  if (text.startsWith('s ') || text.startsWith('es ')) {
    return Gender.neuter;
  }
  return Gender.noGender;
}

Gender _germanCardGender(String text) {
  if (text.startsWith('der ')) {
    return Gender.masculine;
  }
  if (text.startsWith('die ') || text.startsWith('eine ')) {
    return Gender.feminine;
  }
  if (text.startsWith('das ')) {
    return Gender.neuter;
  }
  return Gender.noGender;
}
