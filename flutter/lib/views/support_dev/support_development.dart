import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SupportDevelopment extends StatelessWidget {
  static const routeName = '/support';

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(context.l.navigationDrawerSupportDevelopment)),
      body: Builder(
        builder: (context) => Markdown(
            data: context.l.supportDevelopment,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(p: app_styles.primaryText),
            onTapLink: (href) {
              launchUrl(href, context);
            }),
      ));
}
