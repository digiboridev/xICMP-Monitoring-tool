import 'dart:convert';

import 'package:equatable/equatable.dart';

class AppSettings with EquatableMixin {
  final Duration pingInterval;
  final Duration pingTimeout;

  final int recentSize;
  final int rasterScale;

  final bool andForeground;
  final bool andWakeLock;

  final int v;

  AppSettings._(
    this.pingInterval,
    this.pingTimeout,
    this.recentSize,
    this.rasterScale,
    this.andForeground,
    this.andWakeLock,
  ) : v = 1;

  factory AppSettings.base() {
    return AppSettings._(const Duration(milliseconds: 500), const Duration(milliseconds: 1000), 100, 10, false, false);
  }

  AppSettings copyWith({
    Duration? pingInterval,
    Duration? pingTimeout,
    int? recentSize,
    int? rasterScale,
    bool? andForeground,
    bool? andWakeLock,
  }) {
    return AppSettings._(
      pingInterval ?? this.pingInterval,
      pingTimeout ?? this.pingTimeout,
      recentSize ?? this.recentSize,
      rasterScale ?? this.rasterScale,
      andForeground ?? this.andForeground,
      andWakeLock ?? this.andWakeLock,
    );
  }

  toMap() {
    return {
      'pingInterval': pingInterval.inMilliseconds,
      'pingTimeout': pingTimeout.inMilliseconds,
      'recentSize': recentSize,
      'rasterScale': rasterScale,
      'andForeground': andForeground,
      'andWakeLock': andWakeLock,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    // Migrations
    // int v = json['v'] as int;
    // if (v < 2) {
    //   json['recentSize'] = 1000;
    // }

    return AppSettings._(
      Duration(milliseconds: (map['pingInterval'] as num).toInt()),
      Duration(milliseconds: (map['pingTimeout'] as num).toInt()),
      (map['recentSize'] as num).toInt(),
      (map['rasterScale'] as num).toInt(),
      map['andForeground'] as bool,
      map['andWakeLock'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) => AppSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object> get props {
    return [pingInterval, pingTimeout, recentSize, rasterScale, andForeground, andWakeLock];
  }

  @override
  toString() {
    return 'AppSettings { pingInterval: $pingInterval, pingTimeout: $pingTimeout, recentSize: $recentSize, rasterScale: $rasterScale, andForeground: $andForeground, andWakeLock: $andWakeLock }';
  }
}
