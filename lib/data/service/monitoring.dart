// ignore_for_file: unused_import

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:rxdart/streams.dart';
import 'package:xicmpmt/core/app_logger.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/models/ping.dart';
import 'package:xicmpmt/data/repositories/stats.dart';

class MonitoringService {
  final StatsRepository _repository;
  MonitoringService(this._repository) {
    upsertMonitoring();
  }
  StreamSubscription? _monitoringSubscription;

  upsertMonitoring() async {
    AppLogger.debug('upsertMonitoring: ${_monitoringSubscription != null}', name: 'MonitoringService');
    _monitoringSubscription?.cancel();
    _monitoringSubscription = _createMonitoringStream().listen((ping) => _repository.setPing(ping));
  }

  Stream<Ping> _createMonitoringStream({Duration interval = const Duration(milliseconds: 64)}) async* {
    List<Host> hosts = await _repository.getAllHosts();
    AppLogger.debug('Hosts: $hosts', name: 'MonitoringService');

    // Sequential
    //
    // while (true) {
    //   for (Host host in hosts) {
    //     Ping ping = await _pingTo(host.adress);
    //     yield ping;
    //   }
    //   await Future.delayed(interval);
    // }

    // Pseudo-parallel
    //
    // while (true) {
    //   Iterable<Future<Ping>> jobs = hosts.where((element) => element.enabled).map((e) => _pingTo(e.adress));
    //   List<Ping> pings = await Future.wait(jobs);
    //   for (Ping ping in pings) {
    //     yield ping;
    //   }
    //   await Future.delayed(interval);
    // }

    // Parallel-merged
    //
    // List<Stream<Ping>> streams = [];
    // for (Host host in hosts) {
    //   if (!host.enabled) continue;
    //   streams.add(Stream.periodic(interval, (i) => i).asyncMap((i) => _pingTo(host.adress)));
    // }
    // await for (Ping ping in MergeStream(streams)) {
    //   yield ping;
    // }

    // Parallel-isolated
    //
    late Isolate isolate;
    try {
      final receivePort = ReceivePort();
      isolate = await Isolate.spawn(
        (port) async {
          List<Stream<Ping>> streams = [];
          for (Host host in hosts) {
            if (!host.enabled) continue;
            streams.add(Stream.periodic(interval, (i) => i).asyncMap((i) => _pingTo(host.adress)));
          }
          for (Stream<Ping> stream in streams) {
            stream.listen((ping) => port.send(ping));
          }
        },
        receivePort.sendPort,
      );

      await for (var msg in receivePort) {
        if (msg is Ping) yield msg;
      }
    } finally {
      AppLogger.debug('finally', name: 'MonitoringService');
      isolate.kill(priority: Isolate.immediate);
    }
  }

  static Future<Ping> _pingTo(String adress, {int limit = 1000}) async {
    final sendTime = DateTime.now();
    try {
      final proc = await Process.run('ping', ['-c', '1', adress]).timeout(Duration(milliseconds: limit));
      final out = proc.stdout;
      // print(out);
      if (out is String) {
        final match = RegExp(r'(?<=time\s*=\s*)\d+').stringMatch(out);
        if (match != null) {
          final latency = double.tryParse(match);
          if (latency != null) {
            return Ping(host: adress, time: sendTime, latency: latency.toInt().clamp(0, limit), lost: false);
          }
        }
      }
    } on TimeoutException {
      AppLogger.debug('Ping timeout: $adress', name: 'MonitoringService');
    } catch (e, s) {
      AppLogger.error('$e', name: 'MonitoringService', error: e, stack: s);
    }
    return Ping(host: adress, time: sendTime, latency: limit, lost: true);
  }
}
