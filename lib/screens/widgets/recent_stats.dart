import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/ping.dart';
import 'package:xicmpmt/data/repositories/stats.dart';

class RecentStats extends StatefulWidget {
  final String host;
  final int size;
  const RecentStats({required this.host, this.size = 100, super.key});

  @override
  State<RecentStats> createState() => _RecentStatsState();
}

class _RecentStatsState extends State<RecentStats> {
  final StatsRepository statsRepository = SL.statsRepository;
  Queue<Ping> samplesQueue = Queue();

  int get sum => samplesQueue.fold(0, (sum, ping) => sum + ping.latency);
  int get count => samplesQueue.length;
  int get lossCount => samplesQueue.where((ping) => ping.lost).length;
  int get min => samplesQueue.fold(5000, (min, ping) => ping.latency < min ? ping.latency : min);
  double get avg => sum / count;
  double get lossPercent => lossCount / count * 100;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final queueSize = widget.size;
    final host = widget.host;

    // Watch for incoming samples
    Future.doWhile(() async {
      final event = await statsRepository.eventBus.firstWhere((event) => event is PingAdded && event.ping.host == host);
      final ping = (event as PingAdded).ping;

      if (!mounted) return false;

      samplesQueue.addFirst(ping);
      if (samplesQueue.length > queueSize) samplesQueue.removeLast();
      setState(() {});
      return true;
    });
  }

  @override
  void didUpdateWidget(covariant RecentStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      samplesQueue.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle st = TextStyle(fontSize: 8, fontWeight: FontWeight.w400);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MIN: ${min.clamp(0, 1000).toStringAsFixed(1)} ms', style: st),
        Text('AVG: ${avg.clamp(0, 1000).toStringAsFixed(1)} ms', style: st),
        Text('LOS: ${lossPercent.clamp(0, 100).toStringAsFixed(2)} %', style: st),
      ],
    );
  }
}
