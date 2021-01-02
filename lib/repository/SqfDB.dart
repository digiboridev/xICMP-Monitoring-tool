import 'package:pingstats/repository/IhostDB.dart';
import 'package:sqflite/sqflite.dart';

class SqfDB implements IHostsDB {
  Database _db;

  void _init() async {
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
    await _db.execute('DROP TABLE Host_$hostId');
    await _db.execute('DELETE FROM Hostnames WHERE id = "$hostId"');
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
}
