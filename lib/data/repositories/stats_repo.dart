import 'package:xicmpmt/data/drift/mappers/stats.dart';
import 'package:xicmpmt/data/drift/tables/stats.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/models/ping.dart';

abstract class StatsRepository {
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
  StatsRepositoryDriftImpl(this._dao);

  @override
  Future addHost(Host host) {
    return _dao.addHost(StatsMapper.fromHost(host));
  }

  @override
  Future updateHost(Host host) {
    return _dao.updateHost(StatsMapper.fromHost(host));
  }

  @override
  Future deleteHost(String host) {
    return _dao.deleteHost(host);
  }

  @override
  Future<List<Host>> getAllHosts() {
    return _dao.getAllHosts().then((raw) => raw.map((e) => StatsMapper.toHost(e)).toList());
  }

  @override
  Future addPing(Ping ping) {
    return _dao.addPing(StatsMapper.fromPing(ping));
  }

  @override
  Future<List<Ping>> getAllPings() {
    return _dao.getAllPings().then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList());
  }

  @override
  Future<List<Ping>> getPingsForHost(String host) {
    return _dao.getPingsForHost(host).then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList());
  }

  @override
  Future<List<Ping>> getPingsForHostPeriod(String host, DateTime from, DateTime to) {
    return _dao.getPingsForHostPeriod(host, from, to).then((raw) => raw.map((e) => StatsMapper.toPing(e)).toList());
  }
}
