import 'dart:async';

class EventBus {
  static EventBus? _instance;

  static EventBus get instance {
    _instance ??= EventBus();
    return _instance!;
  }

  final Map<String, StreamController<dynamic>> _streams = {};

  StreamController<T> _ensureController<T>(String name) {
    if (!_streams.containsKey(name)) {
      final controller = StreamController<T>.broadcast();
      _streams[name] = controller;
      return controller;
    }
    return _streams[name] as StreamController<T>;
  }

  /// 触发事件
  void emit<T>(String name, T data) {
    final controller = _ensureController<T>(name);
    controller.add(data);
  }

  /// 监听事件
  StreamSubscription<dynamic> listen(String name, Function(dynamic)? onData) {
    if (!_streams.containsKey(name)) {
      _streams.addAll({name: StreamController<dynamic>.broadcast()});
    }
    return _streams[name]!.stream.listen(onData);
  }

  Stream<T> on<T>(String name) {
    return _ensureController<T>(name).stream;
  }

  StreamSubscription<T> listenTyped<T>(
    String name,
    void Function(T data) onData,
  ) {
    return on<T>(name).listen(onData);
  }
}
