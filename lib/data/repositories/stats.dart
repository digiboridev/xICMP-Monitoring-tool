// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:xicmpmt/data/drift/mappers/stats.dart';
import 'package:xicmpmt/data/drift/tables/stats.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/models/host_stats.dart';
import 'package:xicmpmt/data/models/ping.dart';

sealed class StatsEvent {
  const StatsEvent();

  factory StatsEvent.hostsUpdated(List<Host> hosts) = HostsUpdated;
  factory StatsEvent.pingAdded(Ping ping) = PingAdded;
}

class HostsUpdated extends StatsEvent {
  final List<Host> hosts;
  const HostsUpdated(this.hosts);

  @override
  String toString() => 'HostsUpdated(hosts: $hosts)';
}

class PingAdded extends StatsEvent {
  final Ping ping;
  const PingAdded(this.ping);

  @override
  String toString() => 'PingAdded(ping: $ping)';
}

abstract class StatsRepository {
  Stream<StatsEvent> get eventBus;
  Future addHost(Host host);
  Future updateHost(Host host);
  Future deleteHost(String host);
  Future deleteAllHosts();
  Future disableAllHosts();
  Future enableAllHosts();
  Future<List<Host>> getAllHosts();

  Future setPing(Ping ping);
  Future<List<Ping>> hostPings(String host);
  Future<List<Ping>> hostPingsPeriod(String host, DateTime from, DateTime to);
  Future<List<Ping>> hostPingsPeriodScaled(String host, DateTime from, DateTime to, int scale);
  Future<HostStats> hostStats(String host);
}

class StatsRepositoryDriftImpl implements StatsRepository {
  final StatsDao _dao;
  final _eventBus = StreamController<StatsEvent>.broadcast();

  StatsRepositoryDriftImpl(this._dao) {
    // Schedule periodic wipe of expired pings
    Timer.periodic(const Duration(hours: 1), (timer) => _dao.wipeExpiredPings(DateTime.now().subtract(const Duration(days: 7))));
  }

  @override
  Stream<StatsEvent> get eventBus => _eventBus.stream;

  @override
  Future addHost(Host host) async {
    await _dao.addHost(StatsMapper.fromHost(host));
    _eventBus.add(HostsUpdated(await getAllHosts()));
  }

  @override
  Future updateHost(Host host) async {
    await _dao.updateHost(StatsMapper.fromHost(host));
    _eventBus.add(HostsUpdated(await getAllHosts()));
  }

  @override
  Future deleteHost(String host) async {
    await _dao.deleteHost(host);
    _eventBus.add(HostsUpdated(await getAllHosts()));
  }

  @override
  Future deleteAllHosts() async {
    await _dao.deleteAllHosts();
    _eventBus.add(HostsUpdated(await getAllHosts()));
  }

  @override
  Future disableAllHosts() async {
    final hosts = await getAllHosts();
    for (final host in hosts) {
      await updateHost(host.copyWith(enabled: false));
    }
  }

  @override
  Future enableAllHosts() async {
    final hosts = await getAllHosts();
    for (final host in hosts) {
      await updateHost(host.copyWith(enabled: true));
    }
  }

  @override
  Future<List<Host>> getAllHosts() async {
    return _dao.getAllHosts().then((raw) => raw.map((e) => StatsMapper.toHost(e)).toList());
  }

  @override
  Future setPing(Ping ping) async {
    await _dao.setPing(StatsMapper.fromPing(ping));
    _eventBus.add(PingAdded(ping));
  }

  @override
  Future<List<Ping>> hostPings(String host) async {
    return _dao.hostPings(host).then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList(growable: false));
  }

  @override
  Future<List<Ping>> hostPingsPeriod(String host, DateTime from, DateTime to) async {
    return _dao.hostPingsPeriod(host, from, to).then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList(growable: false));
  }

  @override
  Future<List<Ping>> hostPingsPeriodScaled(String host, DateTime from, DateTime to, int scale) async {
    return _dao.hostPingsPeriodScaled(host, from, to, scale).then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList(growable: false));
  }

  @override
  Future<HostStats> hostStats(String host) async {
    return _dao.hostStats(host);
  }
}
