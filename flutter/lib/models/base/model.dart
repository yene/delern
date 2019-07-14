import 'package:delern_flutter/models/base/keyed_list_item.dart';
import 'package:meta/meta.dart';

abstract class ReadonlyModel implements KeyedListItem {
  String get rootPath;
  Map<String, dynamic> toMap({@required bool isNew});
}

abstract class Model implements KeyedListItem, ReadonlyModel {
  String key;
}
