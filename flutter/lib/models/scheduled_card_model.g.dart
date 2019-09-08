// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_card_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ScheduledCardModel> _$scheduledCardModelSerializer =
    new _$ScheduledCardModelSerializer();

class _$ScheduledCardModelSerializer
    implements StructuredSerializer<ScheduledCardModel> {
  @override
  final Iterable<Type> types = const [ScheduledCardModel, _$ScheduledCardModel];
  @override
  final String wireName = 'ScheduledCardModel';

  @override
  Iterable<Object> serialize(Serializers serializers, ScheduledCardModel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'level',
      serializers.serialize(object.level, specifiedType: const FullType(int)),
      'repeatAt',
      serializers.serialize(object.repeatAt,
          specifiedType: const FullType(DateTime)),
    ];
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
    return result;
  }

  @override
  ScheduledCardModel deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ScheduledCardModelBuilder();

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
        case 'level':
          result.level = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'repeatAt':
          result.repeatAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$ScheduledCardModel extends ScheduledCardModel {
  @override
  final String deckKey;
  @override
  final String key;
  @override
  final int level;
  @override
  final DateTime repeatAt;

  factory _$ScheduledCardModel(
          [void Function(ScheduledCardModelBuilder) updates]) =>
      (new ScheduledCardModelBuilder()..update(updates)).build();

  _$ScheduledCardModel._({this.deckKey, this.key, this.level, this.repeatAt})
      : super._() {
    if (level == null) {
      throw new BuiltValueNullFieldError('ScheduledCardModel', 'level');
    }
    if (repeatAt == null) {
      throw new BuiltValueNullFieldError('ScheduledCardModel', 'repeatAt');
    }
  }

  @override
  ScheduledCardModel rebuild(
          void Function(ScheduledCardModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScheduledCardModelBuilder toBuilder() =>
      new ScheduledCardModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScheduledCardModel &&
        deckKey == other.deckKey &&
        key == other.key &&
        level == other.level &&
        repeatAt == other.repeatAt;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, deckKey.hashCode), key.hashCode), level.hashCode),
        repeatAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ScheduledCardModel')
          ..add('deckKey', deckKey)
          ..add('key', key)
          ..add('level', level)
          ..add('repeatAt', repeatAt))
        .toString();
  }
}

class ScheduledCardModelBuilder
    implements Builder<ScheduledCardModel, ScheduledCardModelBuilder> {
  _$ScheduledCardModel _$v;

  String _deckKey;
  String get deckKey => _$this._deckKey;
  set deckKey(String deckKey) => _$this._deckKey = deckKey;

  String _key;
  String get key => _$this._key;
  set key(String key) => _$this._key = key;

  int _level;
  int get level => _$this._level;
  set level(int level) => _$this._level = level;

  DateTime _repeatAt;
  DateTime get repeatAt => _$this._repeatAt;
  set repeatAt(DateTime repeatAt) => _$this._repeatAt = repeatAt;

  ScheduledCardModelBuilder();

  ScheduledCardModelBuilder get _$this {
    if (_$v != null) {
      _deckKey = _$v.deckKey;
      _key = _$v.key;
      _level = _$v.level;
      _repeatAt = _$v.repeatAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScheduledCardModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ScheduledCardModel;
  }

  @override
  void update(void Function(ScheduledCardModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ScheduledCardModel build() {
    final _$result = _$v ??
        new _$ScheduledCardModel._(
            deckKey: deckKey, key: key, level: level, repeatAt: repeatAt);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
