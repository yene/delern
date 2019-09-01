import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/deck_model.dart';
import 'package:flutter/material.dart';

enum Gender {
  masculine,
  feminine,
  neuter,
  noGender,
}

LinearGradient specifyLearnCardBackgroundGradient(
    DeckType deckType, String text) {
  final textGender = _specifyCardGender(deckType, text);
  return getLearnCardGradientFromGender(textGender);
}

LinearGradient specifyEditCardBackgroundGradient(
    DeckType deckType, String text) {
  final textGender = _specifyCardGender(deckType, text);
  return getEditCardGradientFromGender(textGender);
}

Gender _specifyCardGender(DeckType deckType, String text) {
  if (deckType == DeckType.basic) {
    return Gender.noGender;
  }
  var textGender = Gender.noGender;
  text = text.toLowerCase();
  if (deckType == DeckType.swiss) {
    textGender = _swissCardGender(text);
  } else {
    textGender = _germanCardGender(text);
  }
  return textGender;
}

LinearGradient getEditCardGradientFromGender(Gender gender) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: app_styles.cardBackgroundColors[gender]);

LinearGradient getLearnCardGradientFromGender(Gender gender) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
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
