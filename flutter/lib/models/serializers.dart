library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';

part 'serializers.g.dart';

class FirebaseDateTimeSerializer implements PrimitiveSerializer<DateTime> {
  final bool structured = false;
  @override
  final Iterable<Type> types = BuiltList(<Type>[DateTime]);
  @override
  final String wireName = 'DateTime';

  @override
  Object serialize(Serializers serializers, DateTime dateTime,
          {FullType specifiedType = FullType.unspecified}) =>
      dateTime.millisecondsSinceEpoch;

  @override
  DateTime deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) =>
      serialized is num
          ? DateTime.fromMillisecondsSinceEpoch(serialized.toInt())
          : null;
}

@SerializersFor([
  CardModel,
  DeckModel,
  AccessType,
  DeckType,
  DeckAccessModel,
  ScheduledCardModel,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..add(FirebaseDateTimeSerializer()))
    .build();
