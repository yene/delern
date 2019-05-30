import 'package:flutter_driver/flutter_driver.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

void main() {
  const timeoutDuration = Duration(seconds: 15);

  group('main test', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
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

    test('create_card', () async {
      final frontInput = find.byValueKey('frontCardInput');
      await driver.waitFor(frontInput, timeout: timeoutDuration);
      await driver.enterText('front1');

      await driver.tap(find.byValueKey('backCardInput'),
          timeout: timeoutDuration);
      await driver.enterText('back1');
      await driver.tap(find.byTooltip('Add Card'), timeout: timeoutDuration);

      await driver.waitFor(find.text('Card was added'),
          timeout: timeoutDuration);
    });
  });
}
