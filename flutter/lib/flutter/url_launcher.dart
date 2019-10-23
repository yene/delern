import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrl(String url, BuildContext context) async {
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false);
  } else {
    unawaited(UserMessages.showError(
        () => Scaffold.of(context), 'Could not launch url $url'));
  }
}
