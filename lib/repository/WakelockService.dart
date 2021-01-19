// Wakelockservice provide device stay awake when any isolates is running
// it keeps a list of hosts ids and start foreground and partial wakelock when its contains any ids
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';

class WakelockService {
  // Make class as singleton
  static WakelockService _instance = WakelockService._constructor();
  WakelockService._constructor();
  factory WakelockService() {
    return _instance;
  }

  // List of hosts ids
  List<int> activeIsolates = [];
  // Grand toggler
  bool _wakelockOn = true;

  // Indicates foreground service as started
  bool foregroundPending = false;

  // Open method chanell to provide messages for asquire wakelock from MainActivity.kt
  static const _methodChannel = const MethodChannel('wakeChanell');

  // Indicates wakelock as started
  bool isWakeLockStarted = false;

  // Toggle grand toggler
  set wakelockOn(bool value) {
    _wakelockOn = value;
    check();
  }

  bool get wakelockOn => _wakelockOn;

  // Check the list for contains id and run all shit
  void check() async {
    // Check list and global toggler
    if (activeIsolates.isNotEmpty && wakelockOn) {
      // Check wakelock and start if not
      if (!isWakeLockStarted) {
        _startWakelock();
        isWakeLockStarted = true;
      }
      // Start or update foreground service
      // When starting he marks as pending
      // When starting complete remove pending
      try {
        foregroundPending = true;
        await startForegroundService();
      } catch (e) {
        print(e);
      } finally {
        foregroundPending = false;
      }
    } else {
      // Check wakelock and stop it if not
      if (isWakeLockStarted) {
        _stopWakelock();
        isWakeLockStarted = false;
      }
      // Killing foreground
      // Retry killing if foreground is pending
      try {
        await FlutterForegroundPlugin.stopForegroundService();
        if (foregroundPending) {
          print('foregroun rekill');
          check();
        }
      } catch (e) {
        print(e);
      }
    }
  }

  // Adds host id and run check function
  void addIsolate(int id) {
    activeIsolates.add(id);
    check();
  }

  // Remove host id and run check function
  void deleteIsolate(int id) {
    activeIsolates.remove(id);
    check();
  }

  // Send message for starting wakelock
  void _startWakelock() async {
    String value;
    try {
      value = await _methodChannel.invokeMethod('startWakeLock');
    } catch (e) {
      print(e);
    }
    print(value);
  }

  // Send message for stop wakelock
  void _stopWakelock() async {
    String value;
    try {
      value = await _methodChannel.invokeMethod('stopWakeLock');
    } catch (e) {
      print(e);
    }
    print(value);
  }

  Future startForegroundService() async {
    await FlutterForegroundPlugin.setServiceMethodInterval(seconds: 30);
    await FlutterForegroundPlugin.setServiceMethod(globalForegroundService);
    await FlutterForegroundPlugin.startForegroundService(
      holdWakeLock: false,
      onStarted: () {
        print("Foreground on Started");
      },
      onStopped: () {
        print("Foreground on Stopped");
      },
      title: "Flutter Foreground Service",
      content: "This is Content",
      iconName: "ic_stat_power_settings_new",
    );
  }

  static void globalForegroundService() {
    print('Foreground tick');
  }
}
