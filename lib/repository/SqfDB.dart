import 'package:pingstats/repository/IhostDB.dart';
import 'package:sqflite/sqflite.dart';

class SqfDB implements IHostsDB {
  Database _db;
  Duration expirePeriod = Duration(days: 3);
  int expireCounter = 0;

  Future _init() async {
    print('init db');
    _db = await openDatabase('main7.db', version: 1,
        onCreate: (Database db, int version) async {
      print('creating new db');
      await db.execute(
          'CREATE TABLE Hostnames (id INTEGER PRIMARY KEY AUTOINCREMENT, host TEXT NOT NULL UNIQUE)');
    });
  }

  Future<int> addHost(String hostname) async {
    _db ?? await _init();
    int hostId = await _db
        .rawInsert('INSERT INTO Hostnames("host") VALUES("$hostname")');
    await _db.execute(
        'CREATE TABLE Host_$hostId (time INTEGER PRIMARY KEY, ping INTEGER)');
    return hostId;
  }

  Future<void> deleteHostById(int hostId) async {
    _db ?? await _init();
    await _db.execute('DELETE FROM Hostnames WHERE id = "$hostId"');
    await _db.execute('DROP TABLE Host_$hostId');
  }

  Future<void> deleteHostByName(String hostname) async {
    _db ?? await _init();
    int hostId = (await _db.rawQuery(
        'SELECT id FROM Hostnames WHERE host = "$hostname"'))[0]['id'];

    await deleteHostById(hostId);
  }

  Future<void> addSampleToHostById(int hostId, int time, int ping) async {
    _db ?? await _init();
    await _db.rawInsert(
        'INSERT INTO Host_$hostId("time","ping") VALUES("$time","$ping")');

    await checkExpired();
  }

  Future<void> addSampleToHostByName(
      String hostname, int time, int ping) async {
    _db ?? await _init();
    int hostId = (await _db.rawQuery(
        'SELECT id FROM Hostnames WHERE host = "$hostname"'))[0]['id'];
    await addSampleToHostById(hostId, time, ping);
  }

  Future<List> get hosts async {
    _db ?? await _init();
    return await _db.rawQuery('SELECT * FROM Hostnames');
  }

  Future<List> sampesByHostId(int hostId) async {
    _db ?? await _init();
    return await _db.rawQuery('SELECT * FROM Host_$hostId');
  }

  Future<List> sampesByHostname(String hostname) async {
    _db ?? await _init();
    int hostId = (await _db.rawQuery(
        'SELECT id FROM Hostnames WHERE host = "$hostname"'))[0]['id'];
    return await sampesByHostId(hostId);
  }

  Future<List> getFirstAndLast(int hostId) async {
    _db ?? await _init();
    return await _db.rawQuery(
        'SELECT MIN(time) as first ,MAX(time) as last FROM Host_$hostId');
  }

  Future<List> getPeriodOfSamples(int hostId, Duration period) async {
    int numPeriod = period.inMilliseconds;
    _db ?? await _init();

    return await _db.rawQuery(
        'SELECT time , ping FROM Host_$hostId WHERE time > (SELECT MAX(time) - $numPeriod FROM Host_$hostId)');
  }

  Future autoDelete() async {
    int numPeriod = expirePeriod.inMilliseconds;

    List hostList = await _db.rawQuery('SELECT * FROM Hostnames');

    hostList.forEach((element) async {
      int id = element['id'];
      await _db.rawQuery(
          'DELETE FROM Host_$id WHERE time < (SELECT MAX(time) - $numPeriod FROM Host_$id)');
    });
  }

  Future checkExpired() async {
    expireCounter++;

    if (expireCounter > 10000) {
      await autoDelete();
      expireCounter = 0;
    }
  }
}
