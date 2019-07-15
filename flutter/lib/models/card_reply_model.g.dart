// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_reply_model.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CardReplyModel extends CardReplyModel {
  @override
  final String uid;
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
      (new CardReplyModelBuilder()..update(updates)).build()
          as _$CardReplyModel;

  _$CardReplyModel._(
      {this.uid,
      this.deckKey,
      this.cardKey,
      this.key,
      this.levelBefore,
      this.reply,
      this.timestamp})
      : super._() {
    if (uid == null) {
      throw new BuiltValueNullFieldError('CardReplyModel', 'uid');
    }
    if (deckKey == null) {
      throw new BuiltValueNullFieldError('CardReplyModel', 'deckKey');
    }
  }

  @override
  CardReplyModel rebuild(void Function(CardReplyModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  _$CardReplyModelBuilder toBuilder() =>
      new _$CardReplyModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CardReplyModel &&
        uid == other.uid &&
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
                $jc(
                    $jc($jc($jc(0, uid.hashCode), deckKey.hashCode),
                        cardKey.hashCode),
                    key.hashCode),
                levelBefore.hashCode),
            reply.hashCode),
        timestamp.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('CardReplyModel')
          ..add('uid', uid)
          ..add('deckKey', deckKey)
          ..add('cardKey', cardKey)
          ..add('key', key)
          ..add('levelBefore', levelBefore)
          ..add('reply', reply)
          ..add('timestamp', timestamp))
        .toString();
  }
}

class _$CardReplyModelBuilder extends CardReplyModelBuilder {
  _$CardReplyModel _$v;

  @override
  String get uid {
    _$this;
    return super.uid;
  }

  @override
  set uid(String uid) {
    _$this;
    super.uid = uid;
  }

  @override
  String get deckKey {
    _$this;
    return super.deckKey;
  }

  @override
  set deckKey(String deckKey) {
    _$this;
    super.deckKey = deckKey;
  }

  @override
  String get cardKey {
    _$this;
    return super.cardKey;
  }

  @override
  set cardKey(String cardKey) {
    _$this;
    super.cardKey = cardKey;
  }

  @override
  String get key {
    _$this;
    return super.key;
  }

  @override
  set key(String key) {
    _$this;
    super.key = key;
  }

  @override
  int get levelBefore {
    _$this;
    return super.levelBefore;
  }

  @override
  set levelBefore(int levelBefore) {
    _$this;
    super.levelBefore = levelBefore;
  }

  @override
  bool get reply {
    _$this;
    return super.reply;
  }

  @override
  set reply(bool reply) {
    _$this;
    super.reply = reply;
  }

  @override
  DateTime get timestamp {
    _$this;
    return super.timestamp;
  }

  @override
  set timestamp(DateTime timestamp) {
    _$this;
    super.timestamp = timestamp;
  }

  _$CardReplyModelBuilder() : super._();

  CardReplyModelBuilder get _$this {
    if (_$v != null) {
      super.uid = _$v.uid;
      super.deckKey = _$v.deckKey;
      super.cardKey = _$v.cardKey;
      super.key = _$v.key;
      super.levelBefore = _$v.levelBefore;
      super.reply = _$v.reply;
      super.timestamp = _$v.timestamp;
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
            uid: uid,
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
