import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/card_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Display card with 2 MarkdownBody', (tester) async {
    const frontSide = 'die Mutter';
    const backSide = 'mother';

    // Widget must be wrapped in MaterialApp widget because it uses material
    // related classes.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CardDisplayWidget(
          front: frontSide,
          frontImages: null,
          back: backSide,
          backImages: null,
          tags: const ['#family', '#feminine', '#german'],
          color: app_styles
              .cardBackgroundColors[Gender.feminine].defaultBackground,
          showBack: true,
        ),
      ),
    ));

    // We have 3 tags displayed as chips
    expect(find.byType(Chip), findsNWidgets(3));

    // Make sure that we have 2 Markdown widgets
    expect(find.byType(MarkdownBody), findsNWidgets(2));

    // Iterate all widgets. Compare 4th RichText (after 3 tag chips) with front
    // side and 5th RichText with the back side.
    var richTextWidgetCount = 0;
    for (final widget in tester.allWidgets) {
      if (widget is RichText) {
        richTextWidgetCount++;
        final TextSpan span = widget.text;
        final text = _extractTextFromTextSpan(span);
        if (richTextWidgetCount == 4) {
          expect(text, equals(frontSide));
        } else if (richTextWidgetCount == 5) {
          expect(text, equals(backSide));
        }
      }
    }
    expect(richTextWidgetCount, 5);
  });
}

String _extractTextFromTextSpan(TextSpan span) {
  final textBuffer = StringBuffer(span.text ?? '');
  if (span.children != null) {
    for (final child in span.children) {
      textBuffer.write(_extractTextFromTextSpan(child));
    }
  }
  return textBuffer.toString();
}
