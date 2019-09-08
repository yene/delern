// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_access_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AccessType _$owner = const AccessType._('owner');
const AccessType _$write = const AccessType._('write');
const AccessType _$read = const AccessType._('read');

AccessType _$valueOf(String name) {
  switch (name) {
    case 'owner':
      return _$owner;
    case 'write':
      return _$write;
    case 'read':
      return _$read;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<AccessType> _$values =
    new BuiltSet<AccessType>(const <AccessType>[
  _$owner,
  _$write,
  _$read,
]);

Serializer<AccessType> _$accessTypeSerializer = new _$AccessTypeSerializer();

class _$AccessTypeSerializer implements PrimitiveSerializer<AccessType> {
  @override
  final Iterable<Type> types = const <Type>[AccessType];
  @override
  final String wireName = 'AccessType';

  @override
  Object serialize(Serializers serializers, AccessType object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  AccessType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AccessType.valueOf(serialized as String);
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
