import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/views/helpers/display_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pedantic/pedantic.dart';
import 'package:url_launcher/url_launcher.dart';

class NonScrollingMarkdownWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;

  const NonScrollingMarkdownWidget({this.text, this.textStyle});

  @override
  Widget build(BuildContext context) => Center(
        child: MarkdownBody(
            data: text,
            fitContent: true,
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: textStyle,
              listBullet: textStyle,
              textScaleFactor: MediaQuery.of(context).textScaleFactor,
            ),
            // Use custom image builder to have loading
            imageBuilder: (uri) => buildDisplayImageWidget(uri.toString()),
            onTapLink: (href) async {
              if (await canLaunch(href)) {
                await launch(href, forceSafariVC: false);
              } else {
                unawaited(UserMessages.showError(() => Scaffold.of(context),
                    context.l.couldNotLaunchUrl(href)));
              }
            }),
      );
}
