// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:xicmpmt/data/drift/mappers/stats.dart';
import 'package:xicmpmt/data/drift/tables/stats.dart';
import 'package:xicmpmt/data/models/host.dart';
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
  Future<List<Host>> getAllHosts();
  Future addPing(Ping ping);
  Future<List<Ping>> getAllPings();
  Future<List<Ping>> getPingsForHost(String host);
  Future<List<Ping>> getPingsForHostPeriod(String host, DateTime from, DateTime to);
}

class StatsRepositoryDriftImpl implements StatsRepository {
  final StatsDao _dao;
  final _eventBus = StreamController<StatsEvent>.broadcast();
  StatsRepositoryDriftImpl(this._dao);

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
  Future<List<Host>> getAllHosts() async {
    return _dao.getAllHosts().then((raw) => raw.map((e) => StatsMapper.toHost(e)).toList());
  }

  @override
  Future addPing(Ping ping) async {
    await _dao.addPing(StatsMapper.fromPing(ping));
    _eventBus.add(PingAdded(ping));
  }

  @override
  Future<List<Ping>> getAllPings() async {
    return _dao.getAllPings().then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList());
  }

  @override
  Future<List<Ping>> getPingsForHost(String host) async {
    return _dao.getPingsForHost(host).then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList());
  }

  @override
  Future<List<Ping>> getPingsForHostPeriod(String host, DateTime from, DateTime to) async {
    return _dao.getPingsForHostPeriod(host, from, to).then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList());
  }
}
