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

const double kMinItemHeight = 48;
const double kMinIconHeight = 24;
const double kMinPrimaryTextSize = 19;
const double kMinSecondaryTextSize = 16;
const double kIconDeckPadding = 15;
const double kItemElevation = 4;
const double kItemListHeightRatio = 0.1;
const double kItemListPaddingRatio = kItemListHeightRatio * 0.08;

final Map<Gender, Color> cardBackgroundColors = {
  Gender.noGender: Colors.greenAccent[100],
  Gender.masculine: Colors.lightBlue[200],
  Gender.feminine: Colors.pink[300],
  Gender.neuter: Colors.amberAccent[100],
};

final Color signInBackgroundColor = Colors.greenAccent[100];

const TextStyle primaryText = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.w400,
  color: Color(0xFF212121),
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
