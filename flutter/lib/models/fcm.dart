import 'dart:core';

import 'package:built_value/built_value.dart';
import 'package:delern_flutter/models/base/model.dart';
import 'package:meta/meta.dart';

part 'fcm.g.dart';

abstract class FCM implements Built<FCM, FCMBuilder>, ReadonlyModel {
  String get key;
  String get uid;
  String get name;
  String get language;

  factory FCM([void Function(FCMBuilder) updates]) = _$FCM;
  FCM._();

  Map<String, dynamic> toMap({@required bool isNew}) => {
        'fcm/$uid/$key': {
          'name': name,
          'language': language,
        },
      };

  @override
  String get rootPath => 'fcm/$uid';
}
