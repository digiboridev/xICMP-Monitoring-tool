// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $HostsTableTable extends HostsTable
    with TableInfo<$HostsTableTable, DriftHost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HostsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _adressMeta = const VerificationMeta('adress');
  @override
  late final GeneratedColumn<String> adress =
      GeneratedColumn<String>('adress', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 3,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [adress, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hosts_table';
  @override
  VerificationContext validateIntegrity(Insertable<DriftHost> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('adress')) {
      context.handle(_adressMeta,
          adress.isAcceptableOrUnknown(data['adress']!, _adressMeta));
    } else if (isInserting) {
      context.missing(_adressMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {adress};
  @override
  DriftHost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftHost(
      adress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}adress'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
    );
  }

  @override
  $HostsTableTable createAlias(String alias) {
    return $HostsTableTable(attachedDatabase, alias);
  }
}

class DriftHost extends DataClass implements Insertable<DriftHost> {
  final String adress;
  final bool enabled;
  const DriftHost({required this.adress, required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['adress'] = Variable<String>(adress);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  HostsTableCompanion toCompanion(bool nullToAbsent) {
    return HostsTableCompanion(
      adress: Value(adress),
      enabled: Value(enabled),
    );
  }

  factory DriftHost.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftHost(
      adress: serializer.fromJson<String>(json['adress']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'adress': serializer.toJson<String>(adress),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  DriftHost copyWith({String? adress, bool? enabled}) => DriftHost(
        adress: adress ?? this.adress,
        enabled: enabled ?? this.enabled,
      );
  @override
  String toString() {
    return (StringBuffer('DriftHost(')
          ..write('adress: $adress, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(adress, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftHost &&
          other.adress == this.adress &&
          other.enabled == this.enabled);
}

class HostsTableCompanion extends UpdateCompanion<DriftHost> {
  final Value<String> adress;
  final Value<bool> enabled;
  final Value<int> rowid;
  const HostsTableCompanion({
    this.adress = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HostsTableCompanion.insert({
    required String adress,
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : adress = Value(adress);
  static Insertable<DriftHost> custom({
    Expression<String>? adress,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (adress != null) 'adress': adress,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HostsTableCompanion copyWith(
      {Value<String>? adress, Value<bool>? enabled, Value<int>? rowid}) {
    return HostsTableCompanion(
      adress: adress ?? this.adress,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (adress.present) {
      map['adress'] = Variable<String>(adress.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HostsTableCompanion(')
          ..write('adress: $adress, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PingTableTable extends PingTable
    with TableInfo<$PingTableTable, DriftPing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PingTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
      'host', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES hosts_table (adress) ON DELETE CASCADE'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _latencyMeta =
      const VerificationMeta('latency');
  @override
  late final GeneratedColumn<int> latency = GeneratedColumn<int>(
      'latency', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lostMeta = const VerificationMeta('lost');
  @override
  late final GeneratedColumn<bool> lost = GeneratedColumn<bool>(
      'lost', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("lost" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [host, timestamp, latency, lost];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ping_table';
  @override
  VerificationContext validateIntegrity(Insertable<DriftPing> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('host')) {
      context.handle(
          _hostMeta, host.isAcceptableOrUnknown(data['host']!, _hostMeta));
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('latency')) {
      context.handle(_latencyMeta,
          latency.isAcceptableOrUnknown(data['latency']!, _latencyMeta));
    } else if (isInserting) {
      context.missing(_latencyMeta);
    }
    if (data.containsKey('lost')) {
      context.handle(
          _lostMeta, lost.isAcceptableOrUnknown(data['lost']!, _lostMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {host, timestamp};
  @override
  DriftPing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftPing(
      host: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      latency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}latency'])!,
      lost: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}lost'])!,
    );
  }

  @override
  $PingTableTable createAlias(String alias) {
    return $PingTableTable(attachedDatabase, alias);
  }
}

class DriftPing extends DataClass implements Insertable<DriftPing> {
  final String host;
  final int timestamp;
  final int latency;
  final bool lost;
  const DriftPing(
      {required this.host,
      required this.timestamp,
      required this.latency,
      required this.lost});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['host'] = Variable<String>(host);
    map['timestamp'] = Variable<int>(timestamp);
    map['latency'] = Variable<int>(latency);
    map['lost'] = Variable<bool>(lost);
    return map;
  }

  PingTableCompanion toCompanion(bool nullToAbsent) {
    return PingTableCompanion(
      host: Value(host),
      timestamp: Value(timestamp),
      latency: Value(latency),
      lost: Value(lost),
    );
  }

  factory DriftPing.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftPing(
      host: serializer.fromJson<String>(json['host']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      latency: serializer.fromJson<int>(json['latency']),
      lost: serializer.fromJson<bool>(json['lost']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'host': serializer.toJson<String>(host),
      'timestamp': serializer.toJson<int>(timestamp),
      'latency': serializer.toJson<int>(latency),
      'lost': serializer.toJson<bool>(lost),
    };
  }

  DriftPing copyWith(
          {String? host, int? timestamp, int? latency, bool? lost}) =>
      DriftPing(
        host: host ?? this.host,
        timestamp: timestamp ?? this.timestamp,
        latency: latency ?? this.latency,
        lost: lost ?? this.lost,
      );
  @override
  String toString() {
    return (StringBuffer('DriftPing(')
          ..write('host: $host, ')
          ..write('timestamp: $timestamp, ')
          ..write('latency: $latency, ')
          ..write('lost: $lost')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(host, timestamp, latency, lost);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftPing &&
          other.host == this.host &&
          other.timestamp == this.timestamp &&
          other.latency == this.latency &&
          other.lost == this.lost);
}

class PingTableCompanion extends UpdateCompanion<DriftPing> {
  final Value<String> host;
  final Value<int> timestamp;
  final Value<int> latency;
  final Value<bool> lost;
  final Value<int> rowid;
  const PingTableCompanion({
    this.host = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.latency = const Value.absent(),
    this.lost = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PingTableCompanion.insert({
    required String host,
    required int timestamp,
    required int latency,
    this.lost = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : host = Value(host),
        timestamp = Value(timestamp),
        latency = Value(latency);
  static Insertable<DriftPing> custom({
    Expression<String>? host,
    Expression<int>? timestamp,
    Expression<int>? latency,
    Expression<bool>? lost,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (host != null) 'host': host,
      if (timestamp != null) 'timestamp': timestamp,
      if (latency != null) 'latency': latency,
      if (lost != null) 'lost': lost,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PingTableCompanion copyWith(
      {Value<String>? host,
      Value<int>? timestamp,
      Value<int>? latency,
      Value<bool>? lost,
      Value<int>? rowid}) {
    return PingTableCompanion(
      host: host ?? this.host,
      timestamp: timestamp ?? this.timestamp,
      latency: latency ?? this.latency,
      lost: lost ?? this.lost,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (latency.present) {
      map['latency'] = Variable<int>(latency.value);
    }
    if (lost.present) {
      map['lost'] = Variable<bool>(lost.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PingTableCompanion(')
          ..write('host: $host, ')
          ..write('timestamp: $timestamp, ')
          ..write('latency: $latency, ')
          ..write('lost: $lost, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DB extends GeneratedDatabase {
  _$DB(QueryExecutor e) : super(e);
  late final $HostsTableTable hostsTable = $HostsTableTable(this);
  late final $PingTableTable pingTable = $PingTableTable(this);
  late final StatsDao statsDao = StatsDao(this as DB);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [hostsTable, pingTable];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('hosts_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('ping_table', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}
