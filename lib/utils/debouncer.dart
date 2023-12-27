import 'dart:async';

class Debouncer {
  final Duration? delay;
  Timer? _timer;

  Debouncer({this.delay});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay!, action);
  }

  /// Notifies if the delayed call is active.
  bool get isRunning => _timer?.isActive ?? false;

  /// Cancel the current delayed call.
  void cancel() => _timer?.cancel();
}

abstract class KeyDebouncer {
  static final Map<String, Timer> _map = {};

  static call(String key, Duration delay, Function action) {
    _map[key]?.cancel();
    _map[key] = Timer(delay, () {
      _map.remove(key);
      action();
    });
  }
}
