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
Serializer<DeckModel> _$deckModelSerializer = new _$DeckModelSerializer();

class _$DeckTypeSerializer implements PrimitiveSerializer<DeckType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'basic': 'BASIC',
    'german': 'GERMAN',
    'swiss': 'SWISS',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'BASIC': 'basic',
    'GERMAN': 'german',
    'SWISS': 'swiss',
  };

  @override
  final Iterable<Type> types = const <Type>[DeckType];
  @override
  final String wireName = 'DeckType';

  @override
  Object serialize(Serializers serializers, DeckType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeckType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeckType.valueOf(_fromWire[serialized] ?? serialized as String);
}

class _$DeckModelSerializer implements StructuredSerializer<DeckModel> {
  @override
  final Iterable<Type> types = const [DeckModel, _$DeckModel];
  @override
  final String wireName = 'DeckModel';

  @override
  Iterable<Object> serialize(Serializers serializers, DeckModel object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'deckType',
      serializers.serialize(object.type,
          specifiedType: const FullType(DeckType)),
      'lastSyncAt',
      serializers.serialize(object.lastSyncAt,
          specifiedType: const FullType(DateTime)),
    ];
    if (object.key != null) {
      result
        ..add('key')
        ..add(serializers.serialize(object.key,
            specifiedType: const FullType(String)));
    }
    if (object.name != null) {
      result
        ..add('name')
        ..add(serializers.serialize(object.name,
            specifiedType: const FullType(String)));
    }
    if (object.markdown != null) {
      result
        ..add('markdown')
        ..add(serializers.serialize(object.markdown,
            specifiedType: const FullType(bool)));
    }
    if (object.accepted != null) {
      result
        ..add('accepted')
        ..add(serializers.serialize(object.accepted,
            specifiedType: const FullType(bool)));
    }
    if (object.access != null) {
      result
        ..add('access')
        ..add(serializers.serialize(object.access,
            specifiedType: const FullType(AccessType)));
    }
    if (object.category != null) {
      result
        ..add('category')
        ..add(serializers.serialize(object.category,
            specifiedType: const FullType(String)));
    }
    if (object.latestTagSelection != null) {
      result
        ..add('latestTagSelection')
        ..add(serializers.serialize(object.latestTagSelection,
            specifiedType:
                const FullType(BuiltSet, const [const FullType(String)])));
    }
    return result;
  }

  @override
  DeckModel deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new DeckModelBuilder();

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
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'markdown':
          result.markdown = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
        case 'deckType':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(DeckType)) as DeckType;
          break;
        case 'accepted':
          result.accepted = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
        case 'access':
          result.access = serializers.deserialize(value,
              specifiedType: const FullType(AccessType)) as AccessType;
          break;
        case 'lastSyncAt':
          result.lastSyncAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
        case 'category':
          result.category = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'latestTagSelection':
          result.latestTagSelection.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltSet, const [const FullType(String)]))
              as BuiltSet<Object>);
          break;
      }
    }

    return result.build();
  }
}

class _$DeckModel extends DeckModel {
  @override
  final String key;
  @override
  final String name;
  @override
  final bool markdown;
  @override
  final DeckType type;
  @override
  final bool accepted;
  @override
  final AccessType access;
  @override
  final DateTime lastSyncAt;
  @override
  final String category;
  @override
  final BuiltSet<String> latestTagSelection;
  @override
  final DataListAccessor<CardModel> cards;
  @override
  final DataListAccessor<ScheduledCardModel> scheduledCards;
  @override
  final _ScheduledCardsDueCounter numberOfCardsDue;
  @override
  final DataListAccessor<DeckAccessModel> usersAccess;

  factory _$DeckModel([void Function(DeckModelBuilder) updates]) =>
      (new DeckModelBuilder()..update(updates)).build();

  _$DeckModel._(
      {this.key,
      this.name,
      this.markdown,
      this.type,
      this.accepted,
      this.access,
      this.lastSyncAt,
      this.category,
      this.latestTagSelection,
      this.cards,
      this.scheduledCards,
      this.numberOfCardsDue,
      this.usersAccess})
      : super._() {
    if (type == null) {
      throw new BuiltValueNullFieldError('DeckModel', 'type');
    }
    if (lastSyncAt == null) {
      throw new BuiltValueNullFieldError('DeckModel', 'lastSyncAt');
    }
  }

  @override
  DeckModel rebuild(void Function(DeckModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeckModelBuilder toBuilder() => new DeckModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeckModel &&
        key == other.key &&
        name == other.name &&
        markdown == other.markdown &&
        type == other.type &&
        accepted == other.accepted &&
        access == other.access &&
        lastSyncAt == other.lastSyncAt &&
        category == other.category &&
        latestTagSelection == other.latestTagSelection;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc($jc($jc(0, key.hashCode), name.hashCode),
                                markdown.hashCode),
                            type.hashCode),
                        accepted.hashCode),
                    access.hashCode),
                lastSyncAt.hashCode),
            category.hashCode),
        latestTagSelection.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('DeckModel')
          ..add('key', key)
          ..add('name', name)
          ..add('markdown', markdown)
          ..add('type', type)
          ..add('accepted', accepted)
          ..add('access', access)
          ..add('lastSyncAt', lastSyncAt)
          ..add('category', category)
          ..add('latestTagSelection', latestTagSelection)
          ..add('cards', cards)
          ..add('scheduledCards', scheduledCards)
          ..add('numberOfCardsDue', numberOfCardsDue)
          ..add('usersAccess', usersAccess))
        .toString();
  }
}

class DeckModelBuilder implements Builder<DeckModel, DeckModelBuilder> {
  _$DeckModel _$v;

  String _key;
  String get key => _$this._key;
  set key(String key) => _$this._key = key;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  bool _markdown;
  bool get markdown => _$this._markdown;
  set markdown(bool markdown) => _$this._markdown = markdown;

  DeckType _type;
  DeckType get type => _$this._type;
  set type(DeckType type) => _$this._type = type;

  bool _accepted;
  bool get accepted => _$this._accepted;
  set accepted(bool accepted) => _$this._accepted = accepted;

  AccessType _access;
  AccessType get access => _$this._access;
  set access(AccessType access) => _$this._access = access;

  DateTime _lastSyncAt;
  DateTime get lastSyncAt => _$this._lastSyncAt;
  set lastSyncAt(DateTime lastSyncAt) => _$this._lastSyncAt = lastSyncAt;

  String _category;
  String get category => _$this._category;
  set category(String category) => _$this._category = category;

  SetBuilder<String> _latestTagSelection;
  SetBuilder<String> get latestTagSelection =>
      _$this._latestTagSelection ??= new SetBuilder<String>();
  set latestTagSelection(SetBuilder<String> latestTagSelection) =>
      _$this._latestTagSelection = latestTagSelection;

  DataListAccessor<CardModel> _cards;
  DataListAccessor<CardModel> get cards => _$this._cards;
  set cards(DataListAccessor<CardModel> cards) => _$this._cards = cards;

  DataListAccessor<ScheduledCardModel> _scheduledCards;
  DataListAccessor<ScheduledCardModel> get scheduledCards =>
      _$this._scheduledCards;
  set scheduledCards(DataListAccessor<ScheduledCardModel> scheduledCards) =>
      _$this._scheduledCards = scheduledCards;

  _ScheduledCardsDueCounter _numberOfCardsDue;
  _ScheduledCardsDueCounter get numberOfCardsDue => _$this._numberOfCardsDue;
  set numberOfCardsDue(_ScheduledCardsDueCounter numberOfCardsDue) =>
      _$this._numberOfCardsDue = numberOfCardsDue;

  DataListAccessor<DeckAccessModel> _usersAccess;
  DataListAccessor<DeckAccessModel> get usersAccess => _$this._usersAccess;
  set usersAccess(DataListAccessor<DeckAccessModel> usersAccess) =>
      _$this._usersAccess = usersAccess;

  DeckModelBuilder() {
    DeckModel._initializeBuilder(this);
  }

  DeckModelBuilder get _$this {
    if (_$v != null) {
      _key = _$v.key;
      _name = _$v.name;
      _markdown = _$v.markdown;
      _type = _$v.type;
      _accepted = _$v.accepted;
      _access = _$v.access;
      _lastSyncAt = _$v.lastSyncAt;
      _category = _$v.category;
      _latestTagSelection = _$v.latestTagSelection?.toBuilder();
      _cards = _$v.cards;
      _scheduledCards = _$v.scheduledCards;
      _numberOfCardsDue = _$v.numberOfCardsDue;
      _usersAccess = _$v.usersAccess;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeckModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$DeckModel;
  }

  @override
  void update(void Function(DeckModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$DeckModel build() {
    _$DeckModel _$result;
    try {
      _$result = _$v ??
          new _$DeckModel._(
              key: key,
              name: name,
              markdown: markdown,
              type: type,
              accepted: accepted,
              access: access,
              lastSyncAt: lastSyncAt,
              category: category,
              latestTagSelection: _latestTagSelection?.build(),
              cards: cards,
              scheduledCards: scheduledCards,
              numberOfCardsDue: numberOfCardsDue,
              usersAccess: usersAccess);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'latestTagSelection';
        _latestTagSelection?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'DeckModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
