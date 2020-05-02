import 'dart:async';

import 'package:delern_flutter/views/helpers/localization.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

Future<void> sendInvite(BuildContext context) =>
    Share.share(context.l.inviteToAppMessage);
