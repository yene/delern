import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/non_scrolling_markdown_widget.dart';
import 'package:flutter/material.dart';

class CardSideWidget extends StatelessWidget {
  final String _markdownContent;

  CardSideWidget({
    @required String text,
    Iterable<String> imagesList,
  }) : _markdownContent = imagesList == null
            ? text
            : imagesList
                .fold(
                  StringBuffer(text),
                  (buffer, imageUrl) =>
                      buffer.write('\n\n![alt text]($imageUrl "$text image")'),
                )
                .toString();

  @override
  Widget build(BuildContext context) => NonScrollingMarkdownWidget(
        text: _markdownContent,
        textStyle: app_styles.primaryText,
      );
}
