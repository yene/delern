// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<CardModel> _$cardModelSerializer = new _$CardModelSerializer();

class _$CardModelSerializer implements StructuredSerializer<CardModel> {
  @override
  final Iterable<Type> types = const [CardModel, _$CardModel];
  @override
  final String wireName = 'CardModel';

  @override
  Iterable<Object> serialize(Serializers serializers, CardModel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[];
    if (object.deckKey != null) {
      result
        ..add('deckKey')
        ..add(serializers.serialize(object.deckKey,
            specifiedType: const FullType(String)));
    }
    if (object.key != null) {
      result
        ..add('key')
        ..add(serializers.serialize(object.key,
            specifiedType: const FullType(String)));
    }
    if (object.front != null) {
      result
        ..add('front')
        ..add(serializers.serialize(object.front,
            specifiedType: const FullType(String)));
    }
    if (object.back != null) {
      result
        ..add('back')
        ..add(serializers.serialize(object.back,
            specifiedType: const FullType(String)));
    }
    if (object.createdAt != null) {
      result
        ..add('createdAt')
        ..add(serializers.serialize(object.createdAt,
            specifiedType: const FullType(DateTime)));
    }
    return result;
  }

  @override
  CardModel deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new CardModelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'deckKey':
          result.deckKey = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'front':
          result.front = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'back':
          result.back = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'createdAt':
          result.createdAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$CardModel extends CardModel {
  @override
  final String deckKey;
  @override
  final String key;
  @override
  final String front;
  @override
  final String back;
  @override
  final DateTime createdAt;

  factory _$CardModel([void Function(CardModelBuilder) updates]) =>
      (new CardModelBuilder()..update(updates)).build();

  _$CardModel._({this.deckKey, this.key, this.front, this.back, this.createdAt})
      : super._();

  @override
  CardModel rebuild(void Function(CardModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CardModelBuilder toBuilder() => new CardModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CardModel &&
        deckKey == other.deckKey &&
        key == other.key &&
        front == other.front &&
        back == other.back &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, deckKey.hashCode), key.hashCode), front.hashCode),
            back.hashCode),
        createdAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('CardModel')
          ..add('deckKey', deckKey)
          ..add('key', key)
          ..add('front', front)
          ..add('back', back)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class CardModelBuilder implements Builder<CardModel, CardModelBuilder> {
  _$CardModel _$v;

  String _deckKey;
  String get deckKey => _$this._deckKey;
  set deckKey(String deckKey) => _$this._deckKey = deckKey;

  String _key;
  String get key => _$this._key;
  set key(String key) => _$this._key = key;

  String _front;
  String get front => _$this._front;
  set front(String front) => _$this._front = front;

  String _back;
  String get back => _$this._back;
  set back(String back) => _$this._back = back;

  DateTime _createdAt;
  DateTime get createdAt => _$this._createdAt;
  set createdAt(DateTime createdAt) => _$this._createdAt = createdAt;

  CardModelBuilder();

  CardModelBuilder get _$this {
    if (_$v != null) {
      _deckKey = _$v.deckKey;
      _key = _$v.key;
      _front = _$v.front;
      _back = _$v.back;
      _createdAt = _$v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CardModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$CardModel;
  }

  @override
  void update(void Function(CardModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$CardModel build() {
    final _$result = _$v ??
        new _$CardModel._(
            deckKey: deckKey,
            key: key,
            front: front,
            back: back,
            createdAt: createdAt);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
