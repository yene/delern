import 'dart:core';

import 'package:built_value/built_value.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';

part 'fcm_model.g.dart';

abstract class FCMModel
    implements Built<FCMModel, FCMModelBuilder>, KeyedListItem {
  @override
  String get key;
  String get name;
  String get language;

  factory FCMModel([void Function(FCMModelBuilder) updates]) = _$FCMModel;
  FCMModel._();
}
