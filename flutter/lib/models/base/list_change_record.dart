import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'list_change_record.g.dart';

abstract class ListChangeRecord<E>
    implements Built<ListChangeRecord<E>, ListChangeRecordBuilder<E>> {
  /// How many elements were added at [index] (after removing elements).
  int get addedCount;

  /// Index of where the change occurred.
  int get index;

  /// List that changed.
  BuiltList<E> get object;

  /// Elements that were removed starting at [index] (before adding elements).
  BuiltList<E> get removed;

  factory ListChangeRecord(
          [void Function(ListChangeRecordBuilder<E>) updates]) =
      _$ListChangeRecord<E>;
  ListChangeRecord._();

  factory ListChangeRecord.add(List<E> list, int index, int addedCount) =>
      (ListChangeRecordBuilder<E>()
            ..object = ListBuilder<E>(list)
            ..addedCount = addedCount
            ..index = index
            ..removed = ListBuilder<E>())
          .build();

  factory ListChangeRecord.remove(
          List<E> list, int index, Iterable<E> removed) =>
      (ListChangeRecordBuilder<E>()
            ..object = ListBuilder<E>(list)
            ..addedCount = 0
            ..index = index
            ..removed = ListBuilder<E>(removed))
          .build();

  factory ListChangeRecord.replace(
          List<E> list, int index, Iterable<E> removedElements) =>
      (ListChangeRecordBuilder<E>()
            ..object = ListBuilder<E>(list)
            ..addedCount = removedElements.length
            ..index = index
            ..removed = ListBuilder<E>(removedElements))
          .build();

  /// What elements were added to [object].
  Iterable<E> get added =>
      addedCount == 0 ? const [] : object.getRange(index, index + addedCount);
}
