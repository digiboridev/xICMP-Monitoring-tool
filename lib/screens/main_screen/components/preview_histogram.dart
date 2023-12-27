import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/ping.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/screens/main_screen/components/preview_histogram_painter.dart';

class PreviewHistorgam extends StatefulWidget {
  final String host;
  final int size;
  const PreviewHistorgam({required this.host, this.size = 100, super.key});

  @override
  State<PreviewHistorgam> createState() => _PreviewHistorgamState();
}

class _PreviewHistorgamState extends State<PreviewHistorgam> {
  final StatsRepository statsRepository = SL.statsRepository;
  Queue<Ping> samplesQueue = Queue();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final queueSize = widget.size;
    final host = widget.host;

    // // Load last samples
    // samplesQueue = Queue.from(await statsRepository.getLastPingsForHost(host, queueSize));
    // if (!mounted) return;
    // setState(() {});

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
  void didUpdateWidget(covariant PreviewHistorgam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      samplesQueue.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PreviewHistorgamPainter(samplesQueue, length: widget.size),
      isComplex: true,
    );
  }
}
