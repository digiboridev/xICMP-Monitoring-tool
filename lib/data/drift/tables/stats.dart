import 'package:drift/drift.dart';
import 'package:xicmpmt/data/drift/db.dart';
import 'package:xicmpmt/data/models/host_stats.dart';
part 'stats.g.dart';

@DriftAccessor(tables: [HostsTable, PingTable])
class StatsDao extends DatabaseAccessor<DB> with _$StatsDaoMixin {
  StatsDao(super.db);

  @Deprecated('debug only')
  Future<List<DriftPing>> getAllPings() => select(pingTable).get();

  /// Hosts
  Future addHost(DriftHost host) => into(hostsTable).insert(host, mode: InsertMode.insertOrReplace);
  Future updateHost(DriftHost host) => update(hostsTable).replace(host);
  Future deleteHost(String host) => (delete(hostsTable)..where((t) => t.adress.equals(host))).go();
  Future deleteAllHosts() => delete(hostsTable).go();
  Future<List<DriftHost>> getAllHosts() => select(hostsTable).get();

  /// Pings and stats
  Future setPing(DriftPing ping) => into(pingTable).insert(ping, mode: InsertMode.insertOrReplace);
  Future wipeExpiredPings(DateTime before) => (delete(pingTable)..where((t) => t.timestamp.isSmallerThanValue(before.millisecondsSinceEpoch))).go();

  Future<List<DriftPing>> hostPingsPeriod(String host, DateTime from, DateTime to) async {
    final fromStamp = from.millisecondsSinceEpoch;
    final toStamp = to.millisecondsSinceEpoch;

    final query = customSelect(
      'SELECT latency, timestamp, lost FROM ping_table WHERE host = ? AND timestamp BETWEEN ? AND ? ',
      variables: [Variable.withString(host), Variable.withInt(fromStamp), Variable.withInt(toStamp)],
    );

    final mappedQuery = query.map(
      (row) => DriftPing(
        host: host,
        timestamp: row.read('timestamp'),
        latency: row.read<double>('latency').toInt(),
        lost: row.read('lost'),
      ),
    );

    return await mappedQuery.get();
  }

  Future<List<DriftPing>> hostPingsPeriodScaled(String host, DateTime from, DateTime to, int scale) async {
    final fromStamp = from.millisecondsSinceEpoch;
    final toStamp = to.millisecondsSinceEpoch;
    final periodMs = (toStamp - fromStamp) ~/ scale;

    final query = customSelect(
      'SELECT round(avg(latency)) as latency, timestamp, lost FROM ping_table WHERE host = ? AND timestamp BETWEEN ? AND ? GROUP BY timestamp / ?',
      variables: [Variable.withString(host), Variable.withInt(fromStamp), Variable.withInt(toStamp), Variable.withInt(periodMs)],
    );

    final mappedQuery = query.map(
      (row) => DriftPing(host: host, timestamp: row.read('timestamp'), latency: row.read<double>('latency').toInt(), lost: row.read('lost')),
    );
    return await mappedQuery.get();
  }

  Future<HostStats> hostStats(String host) async {
    final query = customSelect(
      'SELECT avg(latency) as avg, min(latency) as min, max(latency) as max, count(*) as count, count(lost) as lostCount FROM ping_table WHERE host = ?',
      variables: [Variable.withString(host)],
    );
    final result = await query.getSingle();
    double avg = result.read('avg');
    double min = result.read('min');
    double max = result.read('max');
    int count = result.read('count');
    int lostCount = result.read('lostCount');
    int lossPercent = lostCount ~/ count * 100;
    return HostStats(avg.truncate(), min.truncate(), max.truncate(), count, lostCount, lossPercent);
  }
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
  IntColumn get latency => integer()();
  BoolColumn get lost => boolean().withDefault(const Constant(false))();
}
