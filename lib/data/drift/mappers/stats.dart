import 'package:xicmpmt/data/drift/db.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/models/ping.dart';

DriftHost _fromHost(Host host) {
  return DriftHost(adress: host.adress, enabled: host.enabled);
}

Host _toHost(DriftHost host) {
  return Host(adress: host.adress, enabled: host.enabled);
}

DriftPing _fromPing(Ping ping) {
  return DriftPing(host: ping.host, timestamp: ping.time.millisecondsSinceEpoch, latency: ping.latency);
}

Ping _toPing(DriftPing ping) {
  return Ping(host: ping.host, time: DateTime.fromMillisecondsSinceEpoch(ping.timestamp), latency: ping.latency);
}

abstract class StatsMapper {
  static DriftHost fromHost(Host host) => _fromHost(host);
  static Host toHost(DriftHost host) => _toHost(host);

  static DriftPing fromPing(Ping ping) => _fromPing(ping);
  static Ping toPing(DriftPing ping) => _toPing(ping);
}
