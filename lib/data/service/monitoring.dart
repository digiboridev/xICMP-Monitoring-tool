import 'dart:async';
import 'dart:io';

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
    _monitoringSubscription?.cancel();
    _monitoringSubscription = _createMonitoringStream().listen((ping) async {
      await _repository.addPing(ping);
    });
  }

  // stopMonitoring() {
  //   _monitoringSubscription?.cancel();
  // }

  Stream<Ping> _createMonitoringStream({Duration interval = const Duration(milliseconds: 1000)}) async* {
    //
    // Pseudo-parrallel
    //
    // while (true) {
    //   List<Host> hosts = await _repository.getAllHosts();
    //   AppLogger.debug('Hosts: $hosts', name: 'MonitoringService');
    //   Iterable<Future<Ping>> jobs = hosts.where((element) => element.enabled).map((e) => _pingTo(e.adress));
    //   List<Ping> pings = await Future.wait(jobs);
    //   for (Ping ping in pings) {
    //     yield ping;
    //   }
    //   AppLogger.debug('Pings: $pings', name: 'MonitoringService');
    //   await Future.delayed(interval);
    // }

    //
    // Sequential
    //
    // while (true) {
    //   List<Host> hosts = await _repository.getAllHosts();
    //   AppLogger.debug('Hosts: $hosts', name: 'MonitoringService');
    //   for (Host host in hosts) {
    //     Ping ping = await _pingTo(host.adress);
    //     yield ping;
    //   }
    //   await Future.delayed(interval);
    // }

    //
    // Parallel
    //
    List<Host> hosts = await _repository.getAllHosts();
    AppLogger.debug('Hosts: $hosts', name: 'MonitoringService');
    List<Stream<Ping>> streams = [];
    for (Host host in hosts) {
      if (!host.enabled) continue;
      streams.add(Stream.periodic(interval, (i) => i).asyncMap((i) => _pingTo(host.adress)));
    }
    await for (Ping ping in MergeStream(streams)) {
      yield ping;
      AppLogger.debug('$ping', name: 'MonitoringService');
    }
  }

  Future<Ping> _pingTo(String adress) async {
    try {
      final proc = await Process.run('ping', ['-c', '1', adress]).timeout(const Duration(seconds: 1));
      final out = proc.stdout;
      // print(out);
      if (out is String) {
        final match = RegExp(r'(?<=time\s*=\s*)\d+').stringMatch(out);
        if (match != null) {
          final latency = double.tryParse(match);
          if (latency != null) {
            return Ping(host: adress, time: DateTime.now(), latency: latency.toInt());
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error while pinging $adress: $e', name: 'MonitoringService');
    }
    return Ping(host: adress, time: DateTime.now(), latency: null);
  }
}
