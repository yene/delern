import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/card_decoration_widget.dart';
import 'package:delern_flutter/views/helpers/non_scrolling_markdown_widget.dart';
import 'package:delern_flutter/views/helpers/tags_widget.dart';
import 'package:flutter/material.dart';

class CardDisplayWidget extends StatelessWidget {
  final String front;
  final String back;
  final List<String> tags;
  final bool showBack;
  final Color color;

  const CardDisplayWidget({
    @required this.front,
    @required this.back,
    @required this.tags,
    @required this.showBack,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: CardDecorationWidget(
          color: color,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: _buildCardBody(context),
          ),
        ),
      );

  List<Widget> _buildCardBody(BuildContext context) {
    final widgetList = <Widget>[
      TagsWidget(tags: tags),
      NonScrollingMarkdownWidget(
          text: front, textStyle: app_styles.primaryText),
    ];

    if (showBack) {
      widgetList
        ..add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 1),
        ))
        ..add(NonScrollingMarkdownWidget(
          text: back,
          textStyle: app_styles.primaryText,
        ));
    }

    return widgetList;
  }
}
