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
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _latencyMeta =
      const VerificationMeta('latency');
  @override
  late final GeneratedColumn<int> latency = GeneratedColumn<int>(
      'latency', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [host, time, latency];
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
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('latency')) {
      context.handle(_latencyMeta,
          latency.isAcceptableOrUnknown(data['latency']!, _latencyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {host, time};
  @override
  DriftPing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DriftPing(
      host: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      latency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}latency']),
    );
  }

  @override
  $PingTableTable createAlias(String alias) {
    return $PingTableTable(attachedDatabase, alias);
  }
}

class DriftPing extends DataClass implements Insertable<DriftPing> {
  final String host;
  final DateTime time;
  final int? latency;
  const DriftPing({required this.host, required this.time, this.latency});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['host'] = Variable<String>(host);
    map['time'] = Variable<DateTime>(time);
    if (!nullToAbsent || latency != null) {
      map['latency'] = Variable<int>(latency);
    }
    return map;
  }

  PingTableCompanion toCompanion(bool nullToAbsent) {
    return PingTableCompanion(
      host: Value(host),
      time: Value(time),
      latency: latency == null && nullToAbsent
          ? const Value.absent()
          : Value(latency),
    );
  }

  factory DriftPing.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DriftPing(
      host: serializer.fromJson<String>(json['host']),
      time: serializer.fromJson<DateTime>(json['time']),
      latency: serializer.fromJson<int?>(json['latency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'host': serializer.toJson<String>(host),
      'time': serializer.toJson<DateTime>(time),
      'latency': serializer.toJson<int?>(latency),
    };
  }

  DriftPing copyWith(
          {String? host,
          DateTime? time,
          Value<int?> latency = const Value.absent()}) =>
      DriftPing(
        host: host ?? this.host,
        time: time ?? this.time,
        latency: latency.present ? latency.value : this.latency,
      );
  @override
  String toString() {
    return (StringBuffer('DriftPing(')
          ..write('host: $host, ')
          ..write('time: $time, ')
          ..write('latency: $latency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(host, time, latency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DriftPing &&
          other.host == this.host &&
          other.time == this.time &&
          other.latency == this.latency);
}

class PingTableCompanion extends UpdateCompanion<DriftPing> {
  final Value<String> host;
  final Value<DateTime> time;
  final Value<int?> latency;
  final Value<int> rowid;
  const PingTableCompanion({
    this.host = const Value.absent(),
    this.time = const Value.absent(),
    this.latency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PingTableCompanion.insert({
    required String host,
    required DateTime time,
    this.latency = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : host = Value(host),
        time = Value(time);
  static Insertable<DriftPing> custom({
    Expression<String>? host,
    Expression<DateTime>? time,
    Expression<int>? latency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (host != null) 'host': host,
      if (time != null) 'time': time,
      if (latency != null) 'latency': latency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PingTableCompanion copyWith(
      {Value<String>? host,
      Value<DateTime>? time,
      Value<int?>? latency,
      Value<int>? rowid}) {
    return PingTableCompanion(
      host: host ?? this.host,
      time: time ?? this.time,
      latency: latency ?? this.latency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (latency.present) {
      map['latency'] = Variable<int>(latency.value);
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
          ..write('time: $time, ')
          ..write('latency: $latency, ')
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
