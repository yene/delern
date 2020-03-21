import 'dart:core';

import 'package:built_value/built_value.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';

part 'fcm.g.dart';

abstract class FCM implements Built<FCM, FCMBuilder>, KeyedListItem {
  @override
  String get key;
  String get name;
  String get language;

  factory FCM([void Function(FCMBuilder) updates]) = _$FCM;
  FCM._();
}
