import 'package:flutter/material.dart';
import 'package:xicmpmt/data/models/ping.dart';

class TileLatency extends StatefulWidget {
  final Iterable<Ping> samples;
  const TileLatency({required this.samples, super.key});

  @override
  State<TileLatency> createState() => _TileLatencyState();
}

class _TileLatencyState extends State<TileLatency> {
  int lossPercent = 0;
  int avg = 0;
  int min = 0;
  int max = 0;

  @override
  void initState() {
    super.initState();
    computeData();
  }

  @override
  void didUpdateWidget(covariant TileLatency oldWidget) {
    super.didUpdateWidget(oldWidget);
    computeData();
  }

  computeData() {
    int sum = 0;
    int count = 0;
    int lossCount = 0;
    max = 0;
    min = 0;

    for (var item in widget.samples) {
      int? latency = item.latency;

      if (latency == null) {
        lossCount++;
      } else {
        sum += latency;
        if (min == 0 || latency < min) min = latency;
        if (max == 0 || latency > max) max = latency;
      }
      count++;
    }

    if (count > 2) {
      avg = sum ~/ count;
      lossPercent = (lossCount * 100) ~/ count;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle st = TextStyle(fontSize: 10, fontWeight: FontWeight.w400);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AVG: $avg ms', style: st),
        Text('$lossPercent% loss', style: st),
      ],
    );
  }
}
