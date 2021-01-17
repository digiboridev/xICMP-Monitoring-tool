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
  Duration selectedPeriod = Duration(hours: 12);

  HostModel(
    this.hostname,
    this.hostId,
    this.db,
  ) {
    sub = _receivePort.listen((value) {
      print(value);
      addSample(
          DateTime.now().millisecondsSinceEpoch, double.parse(value).toInt());
    });
    // updateSamples();
    updateIsOn();
    updateSamplesPeriod();
    updateSamplesByPeriod();
  }

  final _isOn = BehaviorSubject<bool>();
  Stream<bool> get isOn => _isOn.stream;

  void updateIsOn() {
    _isOn.sink.add(isStared);
  }

  // final _samples = BehaviorSubject<List>();

  // Stream<List> get samples => _samples.stream;

  // void updateSamples() async {
  //   _samples.sink.add(await db.sampesByHostId(hostId));
  // }

  // Getting samples by period

  final _samplesByPeriod = BehaviorSubject<List>();

  Stream<List> get samplesByPeriod => _samplesByPeriod.stream;

  void updateSamplesByPeriod() async {
    _samplesByPeriod.sink
        .add(await db.getPeriodOfSamples(hostId, selectedPeriod));
  }

  set setPeriod(Duration time) {
    selectedPeriod = time;
    updateSamplesByPeriod();
  }

  // Add new sample to host dase

  void addSample(int time, int ping) async {
    await db.addSampleToHostById(hostId, time, ping);
    // updateSamples();
    updateSamplesPeriod();
    updateSamplesByPeriod();
  }

  // Samples period
  // Provide first and last dates of this host

  final _samplesPeriod = BehaviorSubject<Map>();
  Stream<Map> get samplesPeriod => _samplesPeriod.stream;

  void updateSamplesPeriod() async {
    Map answer = (await db.getFirstAndLast(hostId)).first;
    _samplesPeriod.sink.add(answer);
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

  void dispose() {
    print('disposed host');
    // _samples.close();
    sub.cancel();
    _receivePort.close();
    _stopIsolate();

    _isOn.close();
    _samplesPeriod.close();
    _samplesByPeriod.close();
  }
}
