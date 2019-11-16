import 'dart:async';

abstract class StreamWithValue<T> {
  T get value;
  bool get hasValue;
  Stream<T> get updates;
}

// Why not use BehaviorSubject?
// 1. It incapsulates all of: stream, value and add(), i.e. requires another
//    interface / wrapper to expose read-only properties: stream and value.
// 2. If you already have a stream that you want to turn into BehaviorSubject,
//    you have to subscribe to that stream, create a BehaviorSubject, add values
//    to BehaviorSubject and when done, close both stream subscription and
//    BehaviorSubject. This is cumbersome.
// 3. It replays the value to all new stream subscribers, which is redundant
//    when passing value as initialData to StreamBuilder. Passing initialData
//    if it's available is important to avoid unnecessary blinking.
/// [StreamWithValue] implementation that wraps a [Stream] and keeps the latest
/// value that was received from it. Beware that for "push" model, where a
/// (typically broadcast) stream pushes data even when it's not listened to,
/// the [value] will not be tracked if there are no listeners on [updates].
class StreamWithLatestValue<T> implements StreamWithValue<T> {
  Stream<T> _stream;
  bool _hasLatestValue = false;
  T _latestValue;

  StreamWithLatestValue(Stream<T> sourceStream) {
    _stream = sourceStream.map((value) {
      _latestValue = value;
      _hasLatestValue = true;
      return value;
    });
  }

  @override
  Stream<T> get updates => _stream;

  @override
  T get value => _latestValue;

  @override
  bool get hasValue => _hasLatestValue;
}
