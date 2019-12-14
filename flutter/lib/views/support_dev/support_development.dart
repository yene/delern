import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SupportDevelopment extends StatelessWidget {
  static const routeName = '/support';

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text(
              localizations.of(context).navigationDrawerSupportDevelopment)),
      body: Builder(
        builder: (context) => Markdown(
            data: localizations.of(context).supportDevelopment,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(p: app_styles.primaryText),
            onTapLink: (href) {
              launchUrl(href, context);
            }),
      ));
}
