import 'dart:async';

enum Level implements Comparable<Level> {
  debug(value: 1, name: 'debug'),
  info(value: 2, name: 'info'),
  warning(value: 3, name: 'warning'),
  error(value: 4, name: 'error');

  const Level({required this.value, required this.name});

  final int value;
  final String name;

  @override
  int compareTo(Level other) => value.compareTo(other.value);
}

typedef LogEntity = ({Level level, String name, String msg, Object? error, StackTrace? stack, DateTime time});

abstract class AppLogger {
  static final _logController = StreamController<LogEntity>.broadcast();

  static void _capture(String msg, {Level? level, String? name, Object? error, StackTrace? stack, DateTime? time}) {
    level ??= Level.debug;
    name ??= 'ROOT';
    time ??= DateTime.now();

    _logController.add((level: level, name: name, msg: msg, error: error, stack: stack, time: time));
  }

  static void debug(String msg, {String? name}) {
    _capture(msg, level: Level.debug, name: name);
  }

  static void info(String msg, {String? name}) {
    _capture(msg, level: Level.info, name: name);
  }

  static void warning(String msg, {String? name, Object? error, StackTrace? stack}) {
    _capture(msg, level: Level.warning, name: name, error: error, stack: stack);
  }

  static void error(String msg, {String? name, Object? error, StackTrace? stack}) {
    _capture(msg, level: Level.error, name: name, error: error, stack: stack);
  }

  static void forward(LogEntity logEntity) {
    _logController.add(logEntity);
  }

  static Stream<LogEntity> get stream => _logController.stream;
}
