import 'dart:async';

class StreamMuxer<TKey, TEvent> extends Stream<MapEntry<TKey, TEvent>> {
  final Map<TKey, Stream<TEvent>> streams;

  StreamController<MapEntry<TKey, TEvent>> _controller;
  Map<TKey, StreamSubscription<TEvent>> _subscriptions;

  StreamMuxer(this.streams) {
    _controller = StreamController<MapEntry<TKey, TEvent>>(
      onCancel: _onCancel,
      onListen: _onListen,
      onPause: () => _subscriptions.values.forEach((s) => s.pause()),
      onResume: () => _subscriptions.values.forEach((s) => s.resume()),
    );
  }

  @override
  StreamSubscription<MapEntry<TKey, TEvent>> listen(
          void Function(MapEntry<TKey, TEvent> event) onData,
          {Function onError,
          void Function() onDone,
          bool cancelOnError}) =>
      _controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  void _onListen() {
    _subscriptions = streams.map((key, stream) => MapEntry(
        key,
        stream.listen(
          (evt) => _controller.add(MapEntry(key, evt)),
          // TODO(dotdoom): should we cancel only when all of them are done?
          onDone: _onCancel,
          onError: (err, stackTrace) =>
              _controller.addError(MapEntry(key, err), stackTrace),
        )));
  }

  void _onCancel() {
    _subscriptions.values.forEach((sub) => sub.cancel());
    _controller.close();
  }
}
