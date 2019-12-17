import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:flutter/material.dart';

const kPrimarySwatch = Colors.green;
const kLightPrimaryColor = Color(0xFFC8E6C9);
const kAccentColor = Colors.redAccent;
final kScaffoldBackgroundColor = Colors.grey[350];
final kIconColor = Colors.grey[600];
const kSecondaryTextDeckItemColor = Color(0xff757575);
const kEditDismissibleColor = Color(0xFF2196F3);
const kDeleteDismissibleColor = Color(0xFFFF5252);
const kHyperlinkColor = Colors.blueAccent;
// "Facebook brand blue" color per instructions at
// https://developers.facebook.com/docs/facebook-login/for-devices
const kFacebookBlueColor = Color(0xFF1877F2);

const double kMinItemHeight = 48;
const double kMinIconHeight = 24;
const double kMinPrimaryTextSize = 19;
const double kMinSecondaryTextSize = 16;
const double kIconDeckPadding = 15;
const double kItemElevation = 4;
const double kItemListHeightRatio = 0.1;
const double kItemListPaddingRatio = kItemListHeightRatio * 0.08;

final Map<Gender, List<Color>> cardBackgroundColors = {
  Gender.noGender: [const Color(0xFFB1B1B1), const Color(0xFFD2D2D2)],
  Gender.masculine: [Colors.blue[400], Colors.lightBlue[200]],
  Gender.feminine: [Colors.red[400], Colors.red[200]],
  Gender.neuter: [Colors.amber[400], Colors.yellow[200]],
};

final Color signInBackgroundColor = Colors.greenAccent[100];

final TextStyle primaryText = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.w400,
  color: Colors.grey[900],
);

const TextStyle secondaryText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Color(0xff757575),
);

final TextStyle navigationDrawerGroupText = TextStyle(
  fontWeight: FontWeight.w600,
  color: Colors.grey[600],
);

const TextStyle searchBarText = TextStyle(
  color: Colors.white,
  fontSize: 19,
);

const Color menuItemBackgroundColor = Colors.redAccent;

const TextStyle menuItemText = TextStyle(
  color: Colors.white,
);

const TextStyle editCardPrimaryText = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

const TextStyle editCardSecondaryText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

final TextStyle editDeckText = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w400,
  color: Colors.grey[900],
);
