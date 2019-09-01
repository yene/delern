import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:test/test.dart';

void main() {
  group('Swiss German', () {
    const swissDeckType = DeckType.swiss;

    test('feminine', () {
      expect(specifyLearnCardBackgroundGradient(swissDeckType, 'd Muetter'),
          getLearnCardGradientFromGender(Gender.feminine));

      expect(specifyLearnCardBackgroundGradient(swissDeckType, 'e Mappe'),
          getLearnCardGradientFromGender(Gender.feminine));
    });

    test('masculine', () {
      expect(specifyLearnCardBackgroundGradient(swissDeckType, 'de Vater'),
          getLearnCardGradientFromGender(Gender.masculine));

      expect(specifyLearnCardBackgroundGradient(swissDeckType, 'en Vater'),
          getLearnCardGradientFromGender(Gender.masculine));
    });

    test('neuter', () {
      expect(specifyLearnCardBackgroundGradient(swissDeckType, 's Madchen'),
          getLearnCardGradientFromGender(Gender.neuter));

      expect(specifyLearnCardBackgroundGradient(swissDeckType, 'es Madchen'),
          getLearnCardGradientFromGender(Gender.neuter));
    });

    test('noGender', () {
      expect(specifyLearnCardBackgroundGradient(swissDeckType, 'laufen'),
          getLearnCardGradientFromGender(Gender.noGender));
    });
  });

  group('High German', () {
    const germanDeckType = DeckType.german;

    test('feminine', () {
      expect(specifyLearnCardBackgroundGradient(germanDeckType, 'die Mutter'),
          getLearnCardGradientFromGender(Gender.feminine));

      expect(specifyLearnCardBackgroundGradient(germanDeckType, 'eine Lampe'),
          getLearnCardGradientFromGender(Gender.feminine));
    });

    test('masculine', () {
      expect(specifyLearnCardBackgroundGradient(germanDeckType, 'der Vater'),
          getLearnCardGradientFromGender(Gender.masculine));
    });

    test('neuter', () {
      expect(specifyLearnCardBackgroundGradient(germanDeckType, 'das Madchen'),
          getLearnCardGradientFromGender(Gender.neuter));
    });

    test('noGender', () {
      expect(specifyLearnCardBackgroundGradient(germanDeckType, 'laufen'),
          getLearnCardGradientFromGender(Gender.noGender));
    });
  });

  group('Basic', () {
    const basicDeckType = DeckType.basic;

    test('noColor', () {
      expect(specifyLearnCardBackgroundGradient(basicDeckType, 'die Mutter'),
          getLearnCardGradientFromGender(Gender.noGender));
    });
  });
}
