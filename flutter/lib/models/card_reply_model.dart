import 'dart:core';

import 'package:built_value/built_value.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/scheduled_card_model.dart';
import 'package:meta/meta.dart';

part 'card_reply_model.g.dart';

abstract class CardReplyModel
    implements Built<CardReplyModel, CardReplyModelBuilder>, KeyedListItem {
  String get deckKey;
  String get cardKey;
  @nullable
  String get key;
  int get levelBefore;
  bool get reply;
  DateTime get timestamp;

  factory CardReplyModel([void Function(CardReplyModelBuilder) updates]) =
      _$CardReplyModel;
  CardReplyModel._();

  static CardReplyModel fromScheduledCard(ScheduledCardModel sc,
          {@required bool reply}) =>
      (CardReplyModelBuilder()
            ..cardKey = sc.key
            ..deckKey = sc.deckKey
            ..reply = reply
            ..levelBefore = sc.level
            ..timestamp = DateTime.now())
          .build();
}
