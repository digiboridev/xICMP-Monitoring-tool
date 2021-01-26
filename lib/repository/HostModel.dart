import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:xICMP_Monitoring_tool/repository/IhostDB.dart';
import 'package:xICMP_Monitoring_tool/repository/WakelockService.dart';

class IsolateParams {}

class HostModel {
  final String hostname;
  final int hostId;
  final IHostsDB db;
  Isolate _isolate;
  bool pendingIsolate = false;
  ReceivePort _receivePort = ReceivePort();
  StreamSubscription sub;
  bool isStared = false;
  Duration selectedPeriod = Duration(hours: 3);
  int updatesCounter = 0;
  int lengthOfsamples = 0;
  WakelockService wakelockService = WakelockService();

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
    updateIsOn();
    updateSamplesPeriod();
    updateSamplesByPeriod();
    updateLastSamples();
  }

  // Stream indicates sampling status
  final _isOn = BehaviorSubject<bool>();
  Stream<bool> get isOn => _isOn.stream;

  void updateIsOn() {
    _isOn.sink.add(isStared);
  }

  // Stream return samples by period of time setted manualy

  final _samplesByPeriod = BehaviorSubject<List>();

  Stream<List> get samplesByPeriod => _samplesByPeriod.stream;

  void updateSamplesByPeriod() async {
    List result = await db.getPeriodOfSamples(hostId, selectedPeriod);
    lengthOfsamples = result.length;
    _samplesByPeriod.sink.add(result);
  }

  // Set period of time for stream

  set setPeriod(Duration time) {
    selectedPeriod = time;
    updateSamplesByPeriod();
  }

  // Stream samples from last minute

  final _lastSamples = BehaviorSubject<List>();

  Stream<List> get lastSamples => _lastSamples.stream;

  void updateLastSamples() async {
    _lastSamples.sink
        .add(await db.getPeriodOfSamples(hostId, Duration(minutes: 2)));
  }

  // Add new sample to host base
  void addSample(int time, int ping) async {
    await db.addSampleToHostById(hostId, time, ping);

    // Updates every time
    blinkIndicator();
    updateLastSamples();

    // Counter uses for reduce updates on large data
    // Skipping updates if length over 3k and more
    updatesCounter++;
    if (lengthOfsamples < 3000) {
      // print('asdasd');
      updateSamplesByPeriod();
    } else if (lengthOfsamples < 6000) {
      if (updatesCounter > 5) {
        updateSamplesByPeriod();
        updatesCounter = 0;
      }
    } else {
      if (updatesCounter > 25) {
        updateSamplesByPeriod();
        updatesCounter = 0;
      }
    }

    // print(updatesCounter);
    // print(lengthOfsamples);
  }

  // Samples period
  // Provide first and last dates of this host

  final _samplesPeriod = BehaviorSubject<Map>();
  Stream<Map> get samplesPeriod => _samplesPeriod.stream;

  void updateSamplesPeriod() async {
    Map answer = (await db.getFirstAndLast(hostId)).first;
    _samplesPeriod.sink.add(answer);
  }

  // Update indicator
  // Just use for blinking when new data added

  final _updateIndicator = BehaviorSubject<bool>();
  Stream<bool> get updateIndicator => _updateIndicator.stream;

  void blinkIndicator() {
    _updateIndicator.sink.add(true);
  }

  // ICMP ping realization throught vw prosess
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

  // Isolate function
  static void pingIsolate(msg) {
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

  // Starting isolate with pending previous start
  Future _startIsolate() async {
    // Check for isolate spawning
    if (pendingIsolate) {
      print('is pending');
      return;
    }
    print('not pending');

    // Indicates that isolate spawning
    pendingIsolate = true;

    try {
      _isolate = await Isolate.spawn(pingIsolate,
          {'rp': _receivePort.sendPort, 'host': hostname, 'interval': 1});
    } finally {
      pendingIsolate = false;
      isStared = true;
      wakelockService.addIsolate(hostId);
    }
    updateIsOn();
  }

  // Kill isolate and indicate as stop
  Future _stopIsolate() async {
    print('Killing isolate');
    _isolate.kill();
    _isolate = null;
    isStared = false;
    updateIsOn();
    wakelockService.deleteIsolate(hostId);
  }

  // Toggler
  Future toggleIsolate() async {
    if (isStared == false) {
      await _startIsolate();
    } else {
      await _stopIsolate();
    }
  }

  void dispose() {
    print('disposed host');
    sub.cancel();
    _receivePort.close();

    if (isStared) {
      _stopIsolate();
    }

    _isOn.close();
    _samplesPeriod.close();
    _samplesByPeriod.close();
    _updateIndicator.close();
    _lastSamples.close();
  }
}
