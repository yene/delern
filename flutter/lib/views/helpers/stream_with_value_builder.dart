import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:flutter/widgets.dart';

StreamBuilder<T> streamWithValueBuilder<T>({
  @required StreamWithValue<T> streamWithValue,
  @required AsyncWidgetBuilder<T> builder,
  Key key,
}) =>
    StreamBuilder<T>(
      key: key,
      initialData: streamWithValue.value,
      stream: streamWithValue.stream,
      builder: builder,
    );
