import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:flutter/widgets.dart';

/// Build a [StreamBuilder] widget with values supplied from [StreamWithValue]
/// object. DEPRECATED: use [StreamBuilderWithValue] widget instead.
Widget buildStreamBuilderWithValue<T>({
  @required StreamWithValue<T> streamWithValue,
  @required AsyncWidgetBuilder<T> builder,
  Key key,
}) =>
    StreamBuilderWithValue<T>(
      streamWithValue: streamWithValue,
      builder: builder,
      key: key,
    );

@immutable
class StreamBuilderWithValue<T> extends StatefulWidget {
  final StreamWithValue<T> streamWithValue;
  final AsyncWidgetBuilder<T> builder;
  final Key _streamBuilderKey;

  const StreamBuilderWithValue({
    @required this.streamWithValue,
    @required this.builder,
    Key key,
  }) : _streamBuilderKey = key;

  @override
  _StreamBuilderWithValueState<T> createState() =>
      _StreamBuilderWithValueState<T>();
}

class _StreamBuilderWithValueState<T> extends State<StreamBuilderWithValue<T>> {
  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
        key: widget._streamBuilderKey,
        initialData: widget.streamWithValue.value,
        stream: widget.streamWithValue.updates,
        builder: widget.builder,
      );
}
