// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeckType _$basic = const DeckType._('basic');
const DeckType _$german = const DeckType._('german');
const DeckType _$swiss = const DeckType._('swiss');

DeckType _$valueOf(String name) {
  switch (name) {
    case 'basic':
      return _$basic;
    case 'german':
      return _$german;
    case 'swiss':
      return _$swiss;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<DeckType> _$values = new BuiltSet<DeckType>(const <DeckType>[
  _$basic,
  _$german,
  _$swiss,
]);

Serializer<DeckType> _$deckTypeSerializer = new _$DeckTypeSerializer();

class _$DeckTypeSerializer implements PrimitiveSerializer<DeckType> {
  @override
  final Iterable<Type> types = const <Type>[DeckType];
  @override
  final String wireName = 'DeckType';

  @override
  Object serialize(Serializers serializers, DeckType object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  DeckType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeckType.valueOf(serialized as String);
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
