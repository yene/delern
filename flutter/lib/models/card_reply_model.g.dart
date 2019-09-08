// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_reply_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CardReplyModel extends CardReplyModel {
  @override
  final String deckKey;
  @override
  final String cardKey;
  @override
  final String key;
  @override
  final int levelBefore;
  @override
  final bool reply;
  @override
  final DateTime timestamp;

  factory _$CardReplyModel([void Function(CardReplyModelBuilder) updates]) =>
      (new CardReplyModelBuilder()..update(updates)).build();

  _$CardReplyModel._(
      {this.deckKey,
      this.cardKey,
      this.key,
      this.levelBefore,
      this.reply,
      this.timestamp})
      : super._() {
    if (deckKey == null) {
      throw new BuiltValueNullFieldError('CardReplyModel', 'deckKey');
    }
    if (cardKey == null) {
      throw new BuiltValueNullFieldError('CardReplyModel', 'cardKey');
    }
    if (levelBefore == null) {
      throw new BuiltValueNullFieldError('CardReplyModel', 'levelBefore');
    }
    if (reply == null) {
      throw new BuiltValueNullFieldError('CardReplyModel', 'reply');
    }
    if (timestamp == null) {
      throw new BuiltValueNullFieldError('CardReplyModel', 'timestamp');
    }
  }

  @override
  CardReplyModel rebuild(void Function(CardReplyModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CardReplyModelBuilder toBuilder() =>
      new CardReplyModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CardReplyModel &&
        deckKey == other.deckKey &&
        cardKey == other.cardKey &&
        key == other.key &&
        levelBefore == other.levelBefore &&
        reply == other.reply &&
        timestamp == other.timestamp;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc($jc($jc(0, deckKey.hashCode), cardKey.hashCode),
                    key.hashCode),
                levelBefore.hashCode),
            reply.hashCode),
        timestamp.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('CardReplyModel')
          ..add('deckKey', deckKey)
          ..add('cardKey', cardKey)
          ..add('key', key)
          ..add('levelBefore', levelBefore)
          ..add('reply', reply)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class CardReplyModelBuilder
    implements Builder<CardReplyModel, CardReplyModelBuilder> {
  _$CardReplyModel _$v;

  String _deckKey;
  String get deckKey => _$this._deckKey;
  set deckKey(String deckKey) => _$this._deckKey = deckKey;

  String _cardKey;
  String get cardKey => _$this._cardKey;
  set cardKey(String cardKey) => _$this._cardKey = cardKey;

  String _key;
  String get key => _$this._key;
  set key(String key) => _$this._key = key;

  int _levelBefore;
  int get levelBefore => _$this._levelBefore;
  set levelBefore(int levelBefore) => _$this._levelBefore = levelBefore;

  bool _reply;
  bool get reply => _$this._reply;
  set reply(bool reply) => _$this._reply = reply;

  DateTime _timestamp;
  DateTime get timestamp => _$this._timestamp;
  set timestamp(DateTime timestamp) => _$this._timestamp = timestamp;

  CardReplyModelBuilder();

  CardReplyModelBuilder get _$this {
    if (_$v != null) {
      _deckKey = _$v.deckKey;
      _cardKey = _$v.cardKey;
      _key = _$v.key;
      _levelBefore = _$v.levelBefore;
      _reply = _$v.reply;
      _timestamp = _$v.timestamp;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CardReplyModel other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$CardReplyModel;
  }

  @override
  void update(void Function(CardReplyModelBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$CardReplyModel build() {
    final _$result = _$v ??
        new _$CardReplyModel._(
            deckKey: deckKey,
            cardKey: cardKey,
            key: key,
            levelBefore: levelBefore,
            reply: reply,
            timestamp: timestamp);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
