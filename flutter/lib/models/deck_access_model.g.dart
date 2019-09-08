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
Serializer<DeckAccessModel> _$deckAccessModelSerializer =
    new _$DeckAccessModelSerializer();

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

class _$DeckAccessModelSerializer
    implements StructuredSerializer<DeckAccessModel> {
  @override
  final Iterable<Type> types = const [DeckAccessModel, _$DeckAccessModel];
  @override
  final String wireName = 'DeckAccessModel';

  @override
  Iterable<Object> serialize(Serializers serializers, DeckAccessModel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[];
    if (object.key != null) {
      result
        ..add('key')
        ..add(serializers.serialize(object.key,
            specifiedType: const FullType(String)));
    }
    if (object.deckKey != null) {
      result
        ..add('deckKey')
        ..add(serializers.serialize(object.deckKey,
            specifiedType: const FullType(String)));
    }
    if (object.access != null) {
      result
        ..add('access')
        ..add(serializers.serialize(object.access,
            specifiedType: const FullType(AccessType)));
    }
    if (object.email != null) {
      result
        ..add('email')
        ..add(serializers.serialize(object.email,
            specifiedType: const FullType(String)));
    }
    if (object.displayName != null) {
      result
        ..add('displayName')
        ..add(serializers.serialize(object.displayName,
            specifiedType: const FullType(String)));
    }
    if (object.photoUrl != null) {
      result
        ..add('photoUrl')
        ..add(serializers.serialize(object.photoUrl,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  DeckAccessModel deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new DeckAccessModelBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'deckKey':
          result.deckKey = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'access':
          result.access = serializers.deserialize(value,
              specifiedType: const FullType(AccessType)) as AccessType;
          break;
        case 'email':
          result.email = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'displayName':
          result.displayName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'photoUrl':
          result.photoUrl = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
      }
    }

    return result.build();
  }
}

class _$DeckAccessModel extends DeckAccessModel {
  @override
  final String key;
  @override
  final String deckKey;
  @override
  final AccessType access;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final String photoUrl;

  factory _$DeckAccessModel([void Function(DeckAccessModelBuilder) updates]) =>
      (new DeckAccessModelBuilder()..update(updates)).build();

  _$DeckAccessModel._(
      {this.key,
      this.deckKey,
      this.access,
      this.email,
      this.displayName,
      this.photoUrl})
      : super._();

  @override
  DeckAccessModel rebuild(void Function(DeckAccessModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeckAccessModelBuilder toBuilder() =>
      new DeckAccessModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeckAccessModel &&
        key == other.key &&
        deckKey == other.deckKey &&
        access == other.access &&
        email == other.email &&
        displayName == other.displayName &&
        photoUrl == other.photoUrl;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, key.hashCode), deckKey.hashCode),
                    access.hashCode),
                email.hashCode),
            displayName.hashCode),
        photoUrl.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DeckAccessModel')
          ..add('key', key)
          ..add('deckKey', deckKey)
          ..add('access', access)
          ..add('email', email)
          ..add('displayName', displayName)
          ..add('photoUrl', photoUrl))
        .toString();
  }
}

class DeckAccessModelBuilder
    implements Builder<DeckAccessModel, DeckAccessModelBuilder> {
  _$DeckAccessModel _$v;

  String _key;
  String get key => _$this._key;
  set key(String key) => _$this._key = key;

  String _deckKey;
  String get deckKey => _$this._deckKey;
  set deckKey(String deckKey) => _$this._deckKey = deckKey;

  AccessType _access;
  AccessType get access => _$this._access;
  set access(AccessType access) => _$this._access = access;

  String _email;
  String get email => _$this._email;
  set email(String email) => _$this._email = email;

  String _displayName;
  String get displayName => _$this._displayName;
  set displayName(String displayName) => _$this._displayName = displayName;

  String _photoUrl;
  String get photoUrl => _$this._photoUrl;
  set photoUrl(String photoUrl) => _$this._photoUrl = photoUrl;

  DeckAccessModelBuilder();

  DeckAccessModelBuilder get _$this {
    if (_$v != null) {
      _key = _$v.key;
      _deckKey = _$v.deckKey;
      _access = _$v.access;
      _email = _$v.email;
      _displayName = _$v.displayName;
      _photoUrl = _$v.photoUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeckAccessModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$DeckAccessModel;
  }

  @override
  void update(void Function(DeckAccessModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$DeckAccessModel build() {
    final _$result = _$v ??
        new _$DeckAccessModel._(
            key: key,
            deckKey: deckKey,
            access: access,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
