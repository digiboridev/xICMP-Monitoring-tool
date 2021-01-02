import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:pingstats/repository/IhostDB.dart';
import 'package:rxdart/rxdart.dart';
import 'package:easyping/easyping.dart';

class IsolateParams {}

class HostModel {
  final String hostname;
  final int hostId;
  final IHostsDB db;
  Isolate _isolate;
  ReceivePort _receivePort = ReceivePort();
  StreamSubscription sub;
  bool isStared = false;

  HostModel(this.hostname, this.hostId, this.db) {
    sub = _receivePort.listen((value) {
      print(value);
      addSample(
          DateTime.now().microsecondsSinceEpoch, double.parse(value).toInt());
    });
    updateSamples();
  }

  static Future<double> _pingTo(String adress) async {
    ProcessResult result =
        await Process.run('ping', ['-c', '1', '-W', '1', adress]);
    String out = result.stdout;

    if (result.exitCode == 0) {
      return double.parse(
          out.substring(out.indexOf('time=') + 5, out.indexOf(' ms')));
    } else {
      return 0;
    }
  }

  static void isolate(msg) {
    print('Isolate started with: ' + msg.toString());

    void tick() async {
      double pingToAddress = await _pingTo(msg['host']);
      msg['rp'].send(pingToAddress.toString());
      Timer(new Duration(seconds: msg['interval']), tick);
    }

    tick();
  }

  void _startIsolate() async {
    isStared = true;
    _isolate = await Isolate.spawn(isolate,
        {'rp': _receivePort.sendPort, 'host': hostname, 'interval': 1});
  }

  void _stopIsolate() {
    if (_isolate == null) {
      print('Provider Isolate kill tick');
      Timer(Duration(milliseconds: 100), _stopIsolate);
    } else {
      _isolate.kill();
      _isolate = null;
      isStared = false;
    }
  }

  //changes

  void toggleIsolate() {
    if (isStared == false) {
      _startIsolate();
    } else {
      _stopIsolate();
    }
  }

  final _samples = BehaviorSubject<Future<List>>();

  Stream<Future<List>> get samples => _samples.stream;

  void updateSamples() {
    _samples.sink.add(db.sampesByHostId(hostId));
  }

  void addSample(int time, int ping) async {
    await db.addSampleToHostById(hostId, time, ping);
    updateSamples();
  }

  void dispose() {
    print('disposed host');
    _samples.close();
    sub.cancel();
    _receivePort.close();
    _stopIsolate();
  }
}
