// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FCMModel extends FCMModel {
  @override
  final String key;
  @override
  final String name;
  @override
  final String language;

  factory _$FCMModel([void Function(FCMModelBuilder) updates]) =>
      (new FCMModelBuilder()..update(updates)).build();

  _$FCMModel._({this.key, this.name, this.language}) : super._() {
    if (key == null) {
      throw new BuiltValueNullFieldError('FCMModel', 'key');
    }
    if (name == null) {
      throw new BuiltValueNullFieldError('FCMModel', 'name');
    }
    if (language == null) {
      throw new BuiltValueNullFieldError('FCMModel', 'language');
    }
  }

  @override
  FCMModel rebuild(void Function(FCMModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FCMModelBuilder toBuilder() => new FCMModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FCMModel &&
        key == other.key &&
        name == other.name &&
        language == other.language;
  }

  @override
  int get hashCode {
    return $jf(
        $jc($jc($jc(0, key.hashCode), name.hashCode), language.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FCMModel')
          ..add('key', key)
          ..add('name', name)
          ..add('language', language))
        .toString();
  }
}

class FCMModelBuilder implements Builder<FCMModel, FCMModelBuilder> {
  _$FCMModel _$v;

  String _key;
  String get key => _$this._key;
  set key(String key) => _$this._key = key;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _language;
  String get language => _$this._language;
  set language(String language) => _$this._language = language;

  FCMModelBuilder();

  FCMModelBuilder get _$this {
    if (_$v != null) {
      _key = _$v.key;
      _name = _$v.name;
      _language = _$v.language;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FCMModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FCMModel;
  }

  @override
  void update(void Function(FCMModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FCMModel build() {
    final _$result =
        _$v ?? new _$FCMModel._(key: key, name: name, language: language);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
