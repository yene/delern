abstract class KeyedListItem {
  String get key;
}

extension KeyedIterableExtension<E extends KeyedListItem> on Iterable<E> {
  /// Returns an index of the first element where key equals to supplied [key].
  /// If such element is not found, returns -1.
  int indexOfKey(String key) {
    var index = -1;
    // Can't use indexWhere because it's only defined on List, not Iterable:
    // https://github.com/dart-lang/sdk/issues/30275.
    firstWhere((item) {
      index += 1;
      return item.key == key;
    }, orElse: () {
      index = -1;
      return null;
    });
    return index;
  }
}
