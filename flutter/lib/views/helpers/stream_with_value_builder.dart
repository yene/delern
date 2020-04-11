import 'package:delern_flutter/models/base/stream_with_value.dart';
import 'package:flutter/widgets.dart';

/// Build a [StreamBuilder] widget with values supplied from [StreamWithValue]
/// object. DEPRECATED: use [StreamBuilderWithValue] widget instead.
Widget buildStreamBuilderWithValue<T>({
  @required StreamWithValue<T> streamWithValue,
  @required AsyncWidgetBuilder<T> builder,
}) =>
    StreamBuilderWithValue<T>(
      streamWithValue: streamWithValue,
      builder: builder,
    );

@immutable
class StreamBuilderWithValue<T> extends StatefulWidget {
  final StreamWithValue<T> streamWithValue;
  final AsyncWidgetBuilder<T> builder;

  const StreamBuilderWithValue({
    @required this.streamWithValue,
    @required this.builder,
    Key key,
  }) : super(key: key);

  @override
  _StreamBuilderWithValueState<T> createState() =>
      _StreamBuilderWithValueState<T>();
}

class _StreamBuilderWithValueState<T> extends State<StreamBuilderWithValue<T>> {
  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
        // By contract, we have to rebuild from scratch if the stream changes.
        key: ValueKey(widget.streamWithValue.updates),
        initialData: widget.streamWithValue.value,
        stream: widget.streamWithValue.updates,
        builder: widget.builder,
      );
}
