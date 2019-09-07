import 'package:delern_flutter/models/base/keyed_list_item.dart';

abstract class ReadonlyModel implements KeyedListItem {}

abstract class Model implements KeyedListItem, ReadonlyModel {
  String key;
}
