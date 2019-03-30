import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:test/test.dart';

void main() {
  group('Swiss German', () {
    const swissDeckType = DeckType.swiss;

    test('feminine', () {
      expect(specifyCardBackground(swissDeckType, 'd Muetter'),
          app_styles.cardBackgroundColors[Gender.feminine]);

      expect(specifyCardBackground(swissDeckType, 'e Mappe'),
          app_styles.cardBackgroundColors[Gender.feminine]);
    });

    test('masculine', () {
      expect(specifyCardBackground(swissDeckType, 'de Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);

      expect(specifyCardBackground(swissDeckType, 'en Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);
    });

    test('neuter', () {
      expect(specifyCardBackground(swissDeckType, 's Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);

      expect(specifyCardBackground(swissDeckType, 'es Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);
    });

    test('noGender', () {
      expect(specifyCardBackground(swissDeckType, 'laufen'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });

  group('High German', () {
    const germanDeckType = DeckType.german;

    test('feminine', () {
      expect(specifyCardBackground(germanDeckType, 'die Mutter'),
          app_styles.cardBackgroundColors[Gender.feminine]);

      expect(specifyCardBackground(germanDeckType, 'eine Lampe'),
          app_styles.cardBackgroundColors[Gender.feminine]);
    });

    test('masculine', () {
      expect(specifyCardBackground(germanDeckType, 'der Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);
    });

    test('neuter', () {
      expect(specifyCardBackground(germanDeckType, 'das Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);
    });

    test('noGender', () {
      expect(specifyCardBackground(germanDeckType, 'laufen'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });

  group('Basic', () {
    const basicDeckType = DeckType.basic;

    test('noColor', () {
      expect(specifyCardBackground(basicDeckType, 'die Mutter'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });
}
