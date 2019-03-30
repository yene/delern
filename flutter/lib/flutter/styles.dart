import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:flutter/material.dart';

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
  color: Colors.black,
);

const TextStyle secondaryText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.black87,
);

final TextStyle navigationDrawerGroupText = TextStyle(
  fontWeight: FontWeight.w600,
  color: Colors.grey[600],
);

const TextStyle searchBarText = TextStyle(
  color: Colors.white,
  fontSize: 19,
);
