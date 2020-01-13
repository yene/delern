import 'package:delern_flutter/views/card_create_update/card_side_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Create card side', (tester) async {
    final controller = TextEditingController();
    const hint = 'Front side:';
    const key = Key('side_input');
    var currentText = '';
    // Widget must be wrapped in MaterialApp widget because it uses material
    // related classes.
    await tester.pumpWidget(MaterialApp(
      home: CardSideInputWidget(
        key: key,
        controller: controller,
        hint: hint,
        onTextChanged: (text) {
          currentText = text;
        },
      ),
    ));
    expect(find.text(hint), findsOneWidget);
    expect(find.byKey(key), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'front');
    assert(currentText == 'front');
    assert(currentText == controller.text);
  });

  testWidgets('Update card side', (tester) async {
    const hint = 'Front side:';
    const key = Key('side_input');
    var currentText = 'hi';
    final controller = TextEditingController(text: currentText);

    // Widget must be wrapped in MaterialApp widget because it uses material
    // related classes.
    await tester.pumpWidget(MaterialApp(
      home: CardSideInputWidget(
        key: key,
        controller: controller,
        hint: hint,
        onTextChanged: (text) {
          currentText = text;
        },
      ),
    ));
    expect(find.text(hint), findsOneWidget);
    expect(find.text(currentText), findsOneWidget);
    expect(find.byKey(key), findsOneWidget);
    await tester.enterText(find.byType(TextField), '2');
    assert(currentText == '2');
    assert(currentText == controller.text);
  });
}
