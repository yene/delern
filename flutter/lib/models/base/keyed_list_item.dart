abstract class KeyedListItem {
  String get key;
}

extension KeyedListExtension<E extends KeyedListItem> on List<E> {
  /// Returns an index of the first element where key equals to supplied [key].
  /// If such element is not found, returns -1.
  int indexOfKey(String key) => indexWhere((item) => item.key == key);
}
