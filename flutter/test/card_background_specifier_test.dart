import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:test/test.dart';

void main() {
  group('Swiss German', () {
    const swissDeckType = DeckType.swiss;

    test('feminine', () {
      expect(specifyCardBackgroundColors(swissDeckType, 'd Muetter'),
          app_styles.cardBackgroundColors[Gender.feminine]);

      expect(specifyCardBackgroundColors(swissDeckType, 'e Mappe'),
          app_styles.cardBackgroundColors[Gender.feminine]);
    });

    test('masculine', () {
      expect(specifyCardBackgroundColors(swissDeckType, 'de Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);

      expect(specifyCardBackgroundColors(swissDeckType, 'en Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);
    });

    test('neuter', () {
      expect(specifyCardBackgroundColors(swissDeckType, 's Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);

      expect(specifyCardBackgroundColors(swissDeckType, 'es Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);
    });

    test('noGender', () {
      expect(specifyCardBackgroundColors(swissDeckType, 'laufen'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });

  group('High German', () {
    const germanDeckType = DeckType.german;

    test('feminine', () {
      expect(specifyCardBackgroundColors(germanDeckType, 'die Mutter'),
          app_styles.cardBackgroundColors[Gender.feminine]);

      expect(specifyCardBackgroundColors(germanDeckType, 'eine Lampe'),
          app_styles.cardBackgroundColors[Gender.feminine]);
    });

    test('masculine', () {
      expect(specifyCardBackgroundColors(germanDeckType, 'der Vater'),
          app_styles.cardBackgroundColors[Gender.masculine]);
    });

    test('neuter', () {
      expect(specifyCardBackgroundColors(germanDeckType, 'das Madchen'),
          app_styles.cardBackgroundColors[Gender.neuter]);
    });

    test('noGender', () {
      expect(specifyCardBackgroundColors(germanDeckType, 'laufen'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });

  group('Basic', () {
    const basicDeckType = DeckType.basic;

    test('noColor', () {
      expect(specifyCardBackgroundColors(basicDeckType, 'die Mutter'),
          app_styles.cardBackgroundColors[Gender.noGender]);
    });
  });
}
