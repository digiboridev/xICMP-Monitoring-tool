import 'package:drift/drift.dart';
import 'package:xicmpmt/data/drift/db.dart';
part 'stats.g.dart';

@DriftAccessor(tables: [HostsTable, PingTable])
class StatsDao extends DatabaseAccessor<DB> with _$StatsDaoMixin {
  StatsDao(super.db);

  Future addHost(DriftHost host) => into(hostsTable).insert(host);
  Future updateHost(DriftHost host) => update(hostsTable).replace(host);
  Future deleteHost(String host) => (delete(hostsTable)..where((t) => t.adress.equals(host))).go();
  Future<List<DriftHost>> getAllHosts() => select(hostsTable).get();

  Future addPing(DriftPing ping) => into(pingTable).insert(ping);
  Future<List<DriftPing>> getAllPings() => select(pingTable).get();
  Future<List<DriftPing>> getPingsForHost(String host) => (select(pingTable)..where((t) => t.host.equals(host))).get();
  Future<List<DriftPing>> getPingsForHostPeriod(String host, DateTime from, DateTime to) =>
      (select(pingTable)..where((t) => t.host.equals(host) & t.time.isBetweenValues(from, to))).get();
}

@DataClassName('DriftHost')
class HostsTable extends Table {
  @override
  Set<Column> get primaryKey => {adress};
  TextColumn get adress => text().unique().withLength(min: 3).withLength(min: 1)();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

@DataClassName('DriftPing')
class PingTable extends Table {
  @override
  Set<Column> get primaryKey => {host, time};
  TextColumn get host => text().references(HostsTable, #adress, onDelete: KeyAction.cascade)();
  DateTimeColumn get time => dateTime()();
  IntColumn get latency => integer().nullable()();
}
