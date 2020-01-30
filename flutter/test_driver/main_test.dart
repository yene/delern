import 'package:delern_flutter/l10n/app_localizations.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

void main() {
  const timeoutDuration = Duration(seconds: 15);

  group('main test', () {
    FlutterDriver driver;
    AppLocalizations localizations;

    Future<void> tapDialogButton(String text) =>
        driver.tap(find.text(text.toUpperCase()));

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      localizations = AppLocalizations();
    });

    tearDownAll(() async {
      unawaited(driver?.close());
    });

    test('skip_intro', () async {
      final skipButton = find.text('SKIP');
      await driver.waitFor(skipButton);
      await driver.tap(skipButton);
      final doneButton = find.text('DONE');
      await driver.waitFor(doneButton);
      await driver.tap(doneButton);
    });

    test('signin_anonymously', () async {
      final button = find.text('Continue Anonymously');
      await driver.waitFor(button);
      await driver.tap(button);
    });

    test('create_deck', () async {
      final fab = find.byType('FloatingActionButton');
      await driver.waitFor(fab, timeout: timeoutDuration);
      await driver.tap(fab);

      final add = find.text('ADD');
      await driver.waitFor(add);
      await driver.enterText('My Test Deck');
      await driver.waitFor(find.text('My Test Deck'));
      // When text was entered business logic needs some time to enable
      // "Add" button. Otherwise disabled button will be clicked and test fails.
      await Future.delayed(const Duration(seconds: 1));
      await driver.tap(add, timeout: timeoutDuration);
    });

    test('create_cards', () async {
      Future<void> addCard(String front, String back) async {
        final frontInput = find.byValueKey('frontCardInput');
        await driver.waitFor(frontInput, timeout: timeoutDuration);
        await driver.enterText(front);

        await driver.tap(find.byValueKey('backCardInput'),
            timeout: timeoutDuration);
        await driver.enterText(back);
        await driver.tap(find.byTooltip(localizations.addCardTooltip),
            timeout: timeoutDuration);

        await driver.waitFor(find.text(localizations.cardAddedUserMessage),
            timeout: timeoutDuration);
      }

      await addCard('front1', 'back1');
      await addCard('front2', 'back2');

      // Make some changes without saving them.
      await driver.enterText('something');

      // Tapping back should trigger a confirmation dialog for saving changes.
      await driver.tap(find.pageBack());
      await driver.waitFor(find.text(localizations.continueEditingQuestion));
      // Tapping Back "physical" button while the dialog is shown should be
      // ignored, but we can't test it because Flutter Driver does not have that
      // functionality (probably due to Back button not present on iOS devices).
      // Dismiss the confirmation dialog.
      await tapDialogButton(localizations.discard);
    });

    test('learn_cards', () async {
      await driver.tap(find.byType('DeckListItemWidget'));
      await driver.tap(find.byTooltip(localizations.intervalLearningTooltip));

      Future<void> learnCard({
        @required String expectFront,
        @required String expectBack,
        @required bool knows,
      }) async {
        // TODO(ksheremet): getText doesn't work with TextSpan which is used
        // in Markdown text https://github.com/flutter/flutter/issues/16013
        //expect(await driver.getText(find.text('front1')), 'front1');

        final card =
            await driver.getWidgetDiagnostics(find.byType('FlipCardWidget'));
        expect(card['front'], expectFront);
        expect(card['back'], expectBack);

        await driver.tap(find.byType('CardDecorationWidget'));
        await driver.tap(find.byTooltip(knows
            ? localizations.knowCardTooltip
            : localizations.doNotKnowCardTooltip));
      }

      await learnCard(expectFront: 'front1', expectBack: 'back1', knows: true);
      await learnCard(expectFront: 'front2', expectBack: 'back2', knows: false);
      // At this point the learning screen should automatically close because
      // there are no more cards to learn.
    });

    test('delete_card', () async {
      await driver.tap(find.byType('DeckListItemWidget'));
      await driver.tap(find.byTooltip(localizations.intervalLearningTooltip));
      // Since we replied "does no know" to front2, it should be the first in
      // the queue. But before that, dismiss the "learn beyond horizon" dialog.
      await tapDialogButton(localizations.yes);
      // Menu does not have text, use tooltip to find it.
      await driver.tap(find.byTooltip(localizations.menuTooltip));
      await driver.tap(find.text(localizations.delete));
      // And once again in the confirmation dialog.
      await tapDialogButton(localizations.delete);
      // Since we earlier confirmed learning beyond horizon, the learning screen
      // will not close automatically.
      await driver.tap(find.pageBack());
    });

    test('view_learn_card', () async {
      await driver.tap(find.byType('DeckListItemWidget'));
      await driver.tap(find.byTooltip(localizations.viewLearningTooltip));
      await driver.waitFor(find.text('(1/1) My Test Deck'));

      // TODO(ksheremet): getText doesn't work with TextSpan which is used
      // in Markdown text https://github.com/flutter/flutter/issues/16013
      //expect(await driver.getText(find.text('front1')), 'front1');

      var card =
          await driver.getWidgetDiagnostics(find.byType('FlipCardWidget'));
      expect(card['front'], 'front1');
      expect(card['back'], 'back1');

      await driver.tap(find.byType('CardDecorationWidget'));
      await driver.tap(find.byTooltip(localizations.shuffleTooltip));
      await driver.waitFor(find.text('(1/1) My Test Deck'));
      await driver.tap(find.byType('CardDecorationWidget'));

      card = await driver.getWidgetDiagnostics(find.byType('FlipCardWidget'));
      expect(card['front'], 'front1');
      expect(card['back'], 'back1');
    });
  });
}
