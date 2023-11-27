import 'package:drift/drift.dart';
import 'package:xicmpmt/data/drift/db.dart';
part 'stats.g.dart';

@DriftAccessor(tables: [HostsTable, PingTable])
class StatsDao extends DatabaseAccessor<DB> with _$StatsDaoMixin {
  StatsDao(super.db);

  Future addHost(DriftHost host) => into(hostsTable).insert(host, mode: InsertMode.insertOrReplace);
  Future updateHost(DriftHost host) => update(hostsTable).replace(host);
  Future deleteHost(String host) => (delete(hostsTable)..where((t) => t.adress.equals(host))).go();
  Future deleteAllHosts() => delete(hostsTable).go();
  Future<List<DriftHost>> getAllHosts() => select(hostsTable).get();

  Future addPing(DriftPing ping) => into(pingTable).insert(ping, mode: InsertMode.insertOrReplace);
  @Deprecated('test only')
  Future<List<DriftPing>> getAllPings() => select(pingTable).get();
  Future<List<DriftPing>> getPingsForHost(String host) => (select(pingTable)..where((t) => t.host.equals(host))).get();
  Future<List<DriftPing>> getPingsForHostPeriod(String host, DateTime from, DateTime to) => (select(pingTable)
        ..where(
          (t) => t.host.equals(host) & t.timestamp.isBetweenValues(from.millisecondsSinceEpoch, to.millisecondsSinceEpoch),
        ))
      .get();
  Future<List<DriftPing>> getLastPingsForHost(String host, int count) => (select(pingTable)
        ..orderBy(
          [(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)],
        )
        ..where((t) => t.host.equals(host))
        ..limit(count))
      .get();
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
  Set<Column> get primaryKey => {host, timestamp};
  TextColumn get host => text().references(HostsTable, #adress, onDelete: KeyAction.cascade)();
  IntColumn get timestamp => integer()();
  IntColumn get latency => integer().nullable()();
}
