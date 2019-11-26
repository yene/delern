// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_change_record.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListChangeRecord<E> extends ListChangeRecord<E> {
  @override
  final int addedCount;
  @override
  final int index;
  @override
  final BuiltList<E> object;
  @override
  final BuiltList<E> removed;

  factory _$ListChangeRecord(
          [void Function(ListChangeRecordBuilder<E>) updates]) =>
      (new ListChangeRecordBuilder<E>()..update(updates)).build();

  _$ListChangeRecord._({this.addedCount, this.index, this.object, this.removed})
      : super._() {
    if (addedCount == null) {
      throw new BuiltValueNullFieldError('ListChangeRecord', 'addedCount');
    }
    if (index == null) {
      throw new BuiltValueNullFieldError('ListChangeRecord', 'index');
    }
    if (object == null) {
      throw new BuiltValueNullFieldError('ListChangeRecord', 'object');
    }
    if (removed == null) {
      throw new BuiltValueNullFieldError('ListChangeRecord', 'removed');
    }
    if (E == dynamic) {
      throw new BuiltValueMissingGenericsError('ListChangeRecord', 'E');
    }
  }

  @override
  ListChangeRecord<E> rebuild(
          void Function(ListChangeRecordBuilder<E>) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListChangeRecordBuilder<E> toBuilder() =>
      new ListChangeRecordBuilder<E>()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListChangeRecord &&
        addedCount == other.addedCount &&
        index == other.index &&
        object == other.object &&
        removed == other.removed;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, addedCount.hashCode), index.hashCode), object.hashCode),
        removed.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ListChangeRecord')
          ..add('addedCount', addedCount)
          ..add('index', index)
          ..add('object', object)
          ..add('removed', removed))
        .toString();
  }
}

class ListChangeRecordBuilder<E>
    implements Builder<ListChangeRecord<E>, ListChangeRecordBuilder<E>> {
  _$ListChangeRecord<E> _$v;

  int _addedCount;
  int get addedCount => _$this._addedCount;
  set addedCount(int addedCount) => _$this._addedCount = addedCount;

  int _index;
  int get index => _$this._index;
  set index(int index) => _$this._index = index;

  ListBuilder<E> _object;
  ListBuilder<E> get object => _$this._object ??= new ListBuilder<E>();
  set object(ListBuilder<E> object) => _$this._object = object;

  ListBuilder<E> _removed;
  ListBuilder<E> get removed => _$this._removed ??= new ListBuilder<E>();
  set removed(ListBuilder<E> removed) => _$this._removed = removed;

  ListChangeRecordBuilder();

  ListChangeRecordBuilder<E> get _$this {
    if (_$v != null) {
      _addedCount = _$v.addedCount;
      _index = _$v.index;
      _object = _$v.object?.toBuilder();
      _removed = _$v.removed?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListChangeRecord<E> other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$ListChangeRecord<E>;
  }

  @override
  void update(void Function(ListChangeRecordBuilder<E>) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ListChangeRecord<E> build() {
    _$ListChangeRecord<E> _$result;
    try {
      _$result = _$v ??
          new _$ListChangeRecord<E>._(
              addedCount: addedCount,
              index: index,
              object: object.build(),
              removed: removed.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'object';
        object.build();
        _$failedField = 'removed';
        removed.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ListChangeRecord', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
