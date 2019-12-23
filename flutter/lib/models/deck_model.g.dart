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
  static const Map<String, String> _toWire = const <String, String>{
    'basic': 'BASIC',
    'german': 'GERMAN',
    'swiss': 'SWISS',
  };
  static const Map<String, String> _fromWire = const <String, String>{
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
      'markdown',
      serializers.serialize(object.markdown,
          specifiedType: const FullType(bool)),
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
    if (object.cards != null) {
      result
        ..add('cards')
        ..add(serializers.serialize(object.cards,
            specifiedType: const FullType(
                DataListAccessor, const [const FullType(CardModel)])));
    }
    if (object.scheduledCards != null) {
      result
        ..add('scheduledCards')
        ..add(serializers.serialize(object.scheduledCards,
            specifiedType: const FullType(
                DataListAccessor, const [const FullType(ScheduledCardModel)])));
    }
    if (object.numberOfCardsDue != null) {
      result
        ..add('numberOfCardsDue')
        ..add(serializers.serialize(object.numberOfCardsDue,
            specifiedType: const FullType(_ScheduledCardsDueCounter)));
    }
    if (object.usersAccess != null) {
      result
        ..add('usersAccess')
        ..add(serializers.serialize(object.usersAccess,
            specifiedType: const FullType(
                DataListAccessor, const [const FullType(DeckAccessModel)])));
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
        case 'cards':
          result.cards = serializers.deserialize(value,
                  specifiedType: const FullType(
                      DataListAccessor, const [const FullType(CardModel)]))
              as DataListAccessor<CardModel>;
          break;
        case 'scheduledCards':
          result.scheduledCards = serializers.deserialize(value,
              specifiedType: const FullType(DataListAccessor, const [
                const FullType(ScheduledCardModel)
              ])) as DataListAccessor<ScheduledCardModel>;
          break;
        case 'numberOfCardsDue':
          result.numberOfCardsDue = serializers.deserialize(value,
                  specifiedType: const FullType(_ScheduledCardsDueCounter))
              as _ScheduledCardsDueCounter;
          break;
        case 'usersAccess':
          result.usersAccess = serializers.deserialize(value,
              specifiedType: const FullType(DataListAccessor, const [
                const FullType(DeckAccessModel)
              ])) as DataListAccessor<DeckAccessModel>;
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
      this.cards,
      this.scheduledCards,
      this.numberOfCardsDue,
      this.usersAccess})
      : super._() {
    if (markdown == null) {
      throw new BuiltValueNullFieldError('DeckModel', 'markdown');
    }
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
        cards == other.cards &&
        scheduledCards == other.scheduledCards &&
        numberOfCardsDue == other.numberOfCardsDue &&
        usersAccess == other.usersAccess;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc($jc(0, key.hashCode),
                                                name.hashCode),
                                            markdown.hashCode),
                                        type.hashCode),
                                    accepted.hashCode),
                                access.hashCode),
                            lastSyncAt.hashCode),
                        category.hashCode),
                    cards.hashCode),
                scheduledCards.hashCode),
            numberOfCardsDue.hashCode),
        usersAccess.hashCode));
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
    final _$result = _$v ??
        new _$DeckModel._(
            key: key,
            name: name,
            markdown: markdown,
            type: type,
            accepted: accepted,
            access: access,
            lastSyncAt: lastSyncAt,
            category: category,
            cards: cards,
            scheduledCards: scheduledCards,
            numberOfCardsDue: numberOfCardsDue,
            usersAccess: usersAccess);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
