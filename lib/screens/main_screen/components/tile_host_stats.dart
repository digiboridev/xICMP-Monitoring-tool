import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/host_stats.dart';
import 'package:xicmpmt/data/repositories/stats.dart';

class TileHostStats extends StatefulWidget {
  final String host;
  const TileHostStats({required this.host, super.key});

  @override
  State<TileHostStats> createState() => _TileHostStatsState();
}

class _TileHostStatsState extends State<TileHostStats> {
  final StatsRepository statsRepository = SL.statsRepository;

  HostStats? stats;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    stats = await statsRepository.hostStats(widget.host);
    setState(() {});
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 3));
      if (!mounted) return false;
      final update = await statsRepository.hostStats(widget.host);
      if (!mounted) return false;
      setState(() => stats = update);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const tstyle = TextStyle(color: Color(0xffF5F5F5), fontSize: 12, fontWeight: FontWeight.w400);

    if (stats == null) return const Text('Loading...', style: tstyle);
    return Text('AVG: ${stats!.avg} ms  MIN: ${stats!.min} ms  MAX: ${stats!.max} ms  LOSS: ${stats!.lossPercent}% COUNT: ${stats!.count}s', style: tstyle);
  }
}
