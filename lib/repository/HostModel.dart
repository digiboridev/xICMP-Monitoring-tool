import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:pingstats/repository/IhostDB.dart';
import 'package:rxdart/rxdart.dart';

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
    updateIsOn();
  }

  final _isOn = BehaviorSubject<bool>();
  Stream<bool> get isOn => _isOn.stream;

  void updateIsOn() {
    _isOn.sink.add(isStared);
  }

  static Future<double> _pingTo(String adress) async {
    ProcessResult result =
        await Process.run('ping', ['-c', '1', '-W', '1', adress]);
    String out = result.stdout;

    if (result.exitCode == 0) {
      return double.parse(
          out.substring(out.indexOf('time=') + 5, out.indexOf(' ms')));
    } else {
      return 1000;
    }
  }

  static void isolate(msg) {
    print('Isolate started with: ' + msg.toString());

    void tick() async {
      // int rand = Random().nextInt(1000);
      // sleep(Duration(milliseconds: rand));
      // msg['rp'].send(rand.toString());

      double pingToAddress = await _pingTo(msg['host']);
      msg['rp'].send(pingToAddress.toString());
      Timer(new Duration(seconds: msg['interval']), tick);
    }

    tick();
  }

  Future _startIsolate() async {
    isStared = true;
    _isolate = await Isolate.spawn(isolate,
        {'rp': _receivePort.sendPort, 'host': hostname, 'interval': 1});
    updateIsOn();
  }

  Future _stopIsolate() async {
    if (_isolate == null) {
      // print('Provider Isolate kill tick');
      Timer(Duration(milliseconds: 1), _stopIsolate);
    } else {
      _isolate.kill();
      _isolate = null;
      isStared = false;
      updateIsOn();
    }
  }

  Future toggleIsolate() async {
    if (isStared == false) {
      await _startIsolate();
    } else {
      await _stopIsolate();
    }
    // sleep(Duration(seconds: 1));
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

    _isOn.close();
  }
}
