import 'package:delern_flutter/models/base/stream_with_latest_value.dart';
import 'package:flutter/widgets.dart';

/// Build a StreamBuilder widget with values supplied from StreamWithValue
/// object.
// We are not making this a separate Widget because of unnecessary overhead
// associated with creating a class, defining all fields etc.
StreamBuilder<T> buildStreamBuilderWithValue<T>({
  @required StreamWithValue<T> streamWithValue,
  @required AsyncWidgetBuilder<T> builder,
  Key key,
}) =>
    StreamBuilder<T>(
      key: key,
      initialData: streamWithValue.value,
      stream: streamWithValue.updates,
      builder: builder,
    );
