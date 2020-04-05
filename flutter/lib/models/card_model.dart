import 'dart:core';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:delern_flutter/models/base/list_accessor.dart';
import 'package:delern_flutter/models/serializers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'card_model.g.dart';

abstract class CardModel
    implements Built<CardModel, CardModelBuilder>, KeyedListItem {
  @nullable
  String get deckKey;
  @nullable
  @override
  String get key;
  String get front;
  String get back;
  @nullable
  DateTime get createdAt;
  BuiltList<String> get frontImagesUri;
  BuiltList<String> get backImagesUri;

  static Serializer<CardModel> get serializer => _$cardModelSerializer;

  factory CardModel([void Function(CardModelBuilder) updates]) = _$CardModel;
  CardModel._();

  static CardModel fromSnapshot({
    @required String deckKey,
    @required String key,
    @required Map value,
  }) =>
      serializers.deserializeWith(CardModel.serializer, value).rebuild((b) => b
        ..deckKey = deckKey
        ..key = key);

  static void _initializeBuilder(CardModelBuilder b) => b
    ..front = ''
    ..back = '';

  // Tags are non-empty sequences of non-separator characters that start with
  // "#". The list of separator characters should include space, punctuation and
  // is subject to changes.
  //
  // Also the regex will "eat" any space after the tag to avoid turning a set of
  // consequent tags into meaningless spaces.
  static final _tagExtractorRegExp = RegExp(r'#[^\s.,!]+\s*');

  Set<String> get tags => _tagExtractorRegExp
      .allMatches(front)
      // Since the _tagExtractorRegExp includes spaces, trim them away.
      .map((match) => match.group(0).trim())
      .toSet();

  String get frontWithoutTags => front.replaceAll(_tagExtractorRegExp, '');
}

class CardModelListAccessor extends DataListAccessor<CardModel> {
  final String deckId;

  CardModelListAccessor(this.deckId)
      : super(
            FirebaseDatabase.instance.reference().child('cards').child(deckId));

  @override
  CardModel parseItem(String key, dynamic value) =>
      CardModel.fromSnapshot(deckKey: deckId, key: key, value: value);
}
