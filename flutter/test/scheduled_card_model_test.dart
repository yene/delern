import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:test/test.dart';

void main() {
  group('ScheduledCard answer', () {
    test('L(0)', () {
      final scheduledCard = (ScheduledCardModelBuilder()
            ..level = 0
            ..repeatAt = DateTime.now())
          .build();

      expect(
        scheduledCard.answer(knows: true).level,
        1,
      );
      expect(
        scheduledCard.answer(knows: false).level,
        0,
      );
    });

    test('L(0) beyond horizon', () {
      final scheduledCard = (ScheduledCardModelBuilder()
            ..level = 0
            ..repeatAt = DateTime.now().add(const Duration(days: 1)))
          .build();

      expect(
        scheduledCard.answer(knows: true).level,
        0,
      );
      expect(
        scheduledCard.answer(knows: false).level,
        0,
      );
    });

    test('L(max)', () {
      final scheduledCard = (ScheduledCardModelBuilder()
            ..level = ScheduledCardModel.levelDurations.length - 1
            ..repeatAt = DateTime.now())
          .build();

      expect(
        scheduledCard.answer(knows: true).level,
        ScheduledCardModel.levelDurations.length - 1,
      );
      expect(
        scheduledCard.answer(knows: false).level,
        0,
      );
    });

    test('L(max+10)', () {
      final scheduledCard = (ScheduledCardModelBuilder()
            ..level = ScheduledCardModel.levelDurations.length + 10
            ..repeatAt = DateTime.now())
          .build();

      expect(
        scheduledCard.answer(knows: true).level,
        ScheduledCardModel.levelDurations.length - 1,
      );
      expect(
        scheduledCard.answer(knows: false).level,
        0,
      );
    });
  });
}
