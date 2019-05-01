import 'dart:async';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:flutter/material.dart';
import 'package:share/share.dart';

Future<void> sendInvite(BuildContext context) =>
    Share.share(localizations.of(context).inviteToAppMessage);
