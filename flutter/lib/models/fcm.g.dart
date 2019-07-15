// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FCM extends FCM {
  @override
  final String key;
  @override
  final String uid;
  @override
  final String name;
  @override
  final String language;

  factory _$FCM([void Function(FCMBuilder) updates]) =>
      (new FCMBuilder()..update(updates)).build();

  _$FCM._({this.key, this.uid, this.name, this.language}) : super._() {
    if (key == null) {
      throw new BuiltValueNullFieldError('FCM', 'key');
    }
    if (uid == null) {
      throw new BuiltValueNullFieldError('FCM', 'uid');
    }
    if (name == null) {
      throw new BuiltValueNullFieldError('FCM', 'name');
    }
    if (language == null) {
      throw new BuiltValueNullFieldError('FCM', 'language');
    }
  }

  @override
  FCM rebuild(void Function(FCMBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FCMBuilder toBuilder() => new FCMBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FCM &&
        key == other.key &&
        uid == other.uid &&
        name == other.name &&
        language == other.language;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc($jc(0, key.hashCode), uid.hashCode), name.hashCode),
        language.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('FCM')
          ..add('key', key)
          ..add('uid', uid)
          ..add('name', name)
          ..add('language', language))
        .toString();
  }
}

class FCMBuilder implements Builder<FCM, FCMBuilder> {
  _$FCM _$v;

  String _key;
  String get key => _$this._key;
  set key(String key) => _$this._key = key;

  String _uid;
  String get uid => _$this._uid;
  set uid(String uid) => _$this._uid = uid;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _language;
  String get language => _$this._language;
  set language(String language) => _$this._language = language;

  FCMBuilder();

  FCMBuilder get _$this {
    if (_$v != null) {
      _key = _$v.key;
      _uid = _$v.uid;
      _name = _$v.name;
      _language = _$v.language;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FCM other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$FCM;
  }

  @override
  void update(void Function(FCMBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$FCM build() {
    final _$result =
        _$v ?? new _$FCM._(key: key, uid: uid, name: name, language: language);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
