import 'dart:core';

import 'package:built_value/built_value.dart';
import 'package:delern_flutter/models/base/model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

part 'card_reply_model.g.dart';

abstract class CardReplyModel
    implements Built<CardReplyModel, CardReplyModelBuilder>, ReadonlyModel {
  String get uid;
  String get deckKey;

  // The rest are nullable to create a CardReplyModel for deletion of a deck.
  @nullable
  String get cardKey;
  @nullable
  String get key;
  @nullable
  int get levelBefore;
  @nullable
  bool get reply;
  @nullable
  DateTime get timestamp;

  factory CardReplyModel([void Function(CardReplyModelBuilder) updates]) =
      _$CardReplyModel;
  CardReplyModel._();

  @override
  String get rootPath => 'views/$uid/$deckKey/$cardKey';

  @override
  Map<String, dynamic> toMap({@required bool isNew}) => {
        '$rootPath/$key': {
          'levelBefore': 'L$levelBefore',
          'reply': reply ? 'Y' : 'N',
          'timestamp': timestamp.toUtc().millisecondsSinceEpoch,
        },
      };
}

abstract class CardReplyModelBuilder
    implements Builder<CardReplyModel, CardReplyModelBuilder> {
  String uid;
  String deckKey;
  String cardKey;
  // Assign key from the beginning. We always save a new instance of this, so
  // it doesn't matter.
  String key = FirebaseDatabase.instance.reference().push().key;
  int levelBefore;
  bool reply;
  DateTime timestamp = DateTime.now();

  factory CardReplyModelBuilder() = _$CardReplyModelBuilder;
  CardReplyModelBuilder._();
}
