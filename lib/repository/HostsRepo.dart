import 'package:pingstats/repository/HostModel.dart';
import 'package:pingstats/repository/IhostDB.dart';
import 'package:pingstats/repository/SqfDB.dart';

class HostsRepo {
  IHostsDB _db = SqfDB();
  List<HostModel> _hosts;

  Future<void> _loadFromDB() async {
    print(_hosts);
    List h = await _db.hosts;
    _hosts = h.map((e) => HostModel(e['host'], e['id'], _db)).toList();
    print(_hosts);
  }

  Future<List<HostModel>> get hosts async {
    _hosts ?? await _loadFromDB();
    return _hosts;
  }

  Future<void> addHost(String hostname) async {
    List m = await hosts;
    bool contains = false;
    m.forEach((element) {
      if (element.hostname == hostname) {
        print('Already exits');
        contains = true;
      }
    });

    if (!contains) {
      int hostId = await _db.addHost(hostname);
      _hosts.add(HostModel(hostname, hostId, _db));
    }
  }

  Future<void> deleteHost(String hostname) async {
    List m = await hosts;

    HostModel contains;

    m.forEach((element) {
      if (element.hostname == hostname) {
        print('Contains');
        contains = element;
      }
    });

    if (contains != null) {
      contains.dispose();
      _hosts.remove(contains);
      await _db.deleteHostByName(hostname);
    }
  }

  void startAll() {
    _hosts.forEach((HostModel host) {
      !host.isStared ? host.toggleIsolate() : null;
    });
  }

  void stopAll() {
    _hosts.forEach((HostModel host) {
      host.isStared ? host.toggleIsolate() : null;
    });
  }

  Future deleteAll() async {
    _hosts.forEach((element) async {
      element.isStared ? element.toggleIsolate() : null;
      element.dispose();
      await _db.deleteHostByName(element.hostname);
    });
    _hosts.clear();
  }
}
