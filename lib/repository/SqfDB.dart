// import 'package:sqflite/sqflite.dart';
// import 'package:xICMP_Monitoring_tool/repository/IhostDB.dart';

// class SqfDB implements IHostsDB {
//   Database _db;
//   Duration _expirePeriod = Duration(days: 7);
//   int _expireCounter = 0;

//   // Load or create db if empty
//   Future _init() async {
//     print('init db');
//     _db = await openDatabase('ping.db', version: 1,
//         onCreate: (Database db, int version) async {
//       print('creating new db');
//       await db.execute(
//           'CREATE TABLE Hostnames (id INTEGER PRIMARY KEY AUTOINCREMENT, host TEXT NOT NULL UNIQUE)');
//     });
//   }

//   // Add host id to hosts table and create host table
//   Future<int> addHost(String hostname) async {
//     _db ?? await _init();
//     int hostId = await _db
//         .rawInsert('INSERT INTO Hostnames("host") VALUES("$hostname")');
//     await _db.execute(
//         'CREATE TABLE Host_$hostId (time INTEGER PRIMARY KEY, ping INTEGER)');
//     return hostId;
//   }

//   // Delete host table and remove from table of hosts
//   Future<void> deleteHostById(int hostId) async {
//     _db ?? await _init();
//     await _db.execute('DELETE FROM Hostnames WHERE id = "$hostId"');
//     await _db.execute('DROP TABLE Host_$hostId');
//   }

//   // Same thing but by name
//   Future<void> deleteHostByName(String hostname) async {
//     _db ?? await _init();
//     int hostId = (await _db.rawQuery(
//         'SELECT id FROM Hostnames WHERE host = "$hostname"'))[0]['id'];

//     await deleteHostById(hostId);
//   }

//   // Add sample to host table by hist id
//   Future<void> addSampleToHostById(int hostId, int time, int ping) async {
//     _db ?? await _init();
//     await _db.rawInsert(
//         'INSERT INTO Host_$hostId("time","ping") VALUES("$time","$ping")');

//     await _checkExpired();
//   }

//   // Same thing but by name
//   Future<void> addSampleToHostByName(
//       String hostname, int time, int ping) async {
//     _db ?? await _init();
//     int hostId = (await _db.rawQuery(
//         'SELECT id FROM Hostnames WHERE host = "$hostname"'))[0]['id'];
//     await addSampleToHostById(hostId, time, ping);
//   }

//   // Return list of host ids and names
//   Future<List> get hosts async {
//     _db ?? await _init();
//     return await _db.rawQuery('SELECT * FROM Hostnames');
//   }

//   // Return all samples in host table
//   Future<List> sampesByHostId(int hostId) async {
//     _db ?? await _init();
//     return await _db.rawQuery('SELECT * FROM Host_$hostId');
//   }

//   // Same thing but by name
//   Future<List> sampesByHostname(String hostname) async {
//     _db ?? await _init();
//     int hostId = (await _db.rawQuery(
//         'SELECT id FROM Hostnames WHERE host = "$hostname"'))[0]['id'];
//     return await sampesByHostId(hostId);
//   }

//   // Return first and last sample from host table
//   Future<List> getFirstAndLast(int hostId) async {
//     _db ?? await _init();
//     return await _db.rawQuery(
//         'SELECT MIN(time) as first ,MAX(time) as last FROM Host_$hostId');
//   }

//   // Return samples that are only in the specified period
//   Future<List> getPeriodOfSamples(int hostId, Duration period) async {
//     int numPeriod = period.inMilliseconds;
//     _db ?? await _init();

//     return await _db.rawQuery(
//         'SELECT time , ping FROM Host_$hostId WHERE time > (SELECT MAX(time) - $numPeriod FROM Host_$hostId)');
//   }

//   // Detele expired samples in all host tables
//   Future _autoDelete() async {
//     int numPeriod = _expirePeriod.inMilliseconds;

//     List hostList = await _db.rawQuery('SELECT * FROM Hostnames');

//     hostList.forEach((element) async {
//       int id = element['id'];
//       await _db.rawQuery(
//           'DELETE FROM Host_$id WHERE time < (SELECT MAX(time) - $numPeriod FROM Host_$id)');
//     });
//   }

//   // Trigger autodelete after 10000 uses for optimization
//   Future _checkExpired() async {
//     _expireCounter++;

//     if (_expireCounter > 10000) {
//       await _autoDelete();
//       _expireCounter = 0;
//     }
//   }
// }
