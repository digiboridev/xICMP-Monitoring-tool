import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/models/ping.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';
import 'package:xicmpmt/screens/widgets/interactive_graph.dart';
import 'package:xicmpmt/screens/widgets/blinking_circle.dart';
import 'package:xicmpmt/screens/widgets/tile_graph.dart';
import 'package:xicmpmt/screens/widgets/tile_latency.dart';

class HostTile extends StatefulWidget {
  final Host host;
  const HostTile({required this.host, super.key});

  @override
  State<HostTile> createState() => _HostTileState();
}

class _HostTileState extends State<HostTile> {
  final StatsRepository statsRepository = SL.statsRepository;
  final MonitoringService monitoringService = SL.monitoringService;

  Queue<Ping> lastSamples = Queue();
  int lastSamplesCount = 100;

  bool expanded = false;

  void toggleRunning() {
    statsRepository.updateHost(widget.host.copyWith(enabled: !widget.host.enabled));
    monitoringService.upsertMonitoring();
    print('toggle running');
  }

  void deleteHost(BuildContext context) {
    statsRepository.deleteHost(widget.host.adress);
    monitoringService.upsertMonitoring();
    print('delete host');
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    lastSamples = Queue.from(await statsRepository.getLastPingsForHost(widget.host.adress, lastSamplesCount));
    // statsRepository.eventBus.where((event) => event is PingAdded && event.ping.host == widget.host.adress).cast<PingAdded>().forEach((event) {
    //   if (!mounted) return;
    //   lastSamples.addFirst(event.ping);
    //   if (lastSamples.length > lastSamplesCount) lastSamples.removeLast();
    //   setState(() {});
    // });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          // onDoubleTap: toggleRunning,
          onTap: () => setState(() => expanded = !expanded),
          child: Opacity(
            opacity: widget.host.enabled ? 1 : 0.5,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RepaintBoundary(
                  child: StreamBuilder(
                    stream: statsRepository.eventBus.where((event) => event is PingAdded && event.ping.host == widget.host.adress),
                    builder: (context, snapshot) => BlinkingCircle(),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: RepaintBoundary(
                    child: Text(key: Key(widget.host.adress), widget.host.adress, overflow: TextOverflow.fade, softWrap: false),
                  ),
                ),
                SizedBox(width: 16),
                RepaintBoundary(
                  child: SizedBox(width: 60, child: TileLatency(samples: lastSamples)),
                ),
                RepaintBoundary(
                  child: SizedBox(width: 70, height: 24, child: CustomPaint(painter: TileGraph(lastSamples, length: lastSamplesCount))),
                ),
                Icon(!expanded ? Icons.arrow_drop_down : Icons.arrow_drop_up),
              ],
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedContainer(
            height: expanded ? 250 : 0,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: ClipRRect(
              child: OverflowBox(
                maxHeight: 250,
                child: expanded
                    ? Column(
                        children: [
                          // TileHostStats(host: widget.host.adress),
                          Expanded(child: InteractiveGraph(host: widget.host.adress)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        widget.host.enabled ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                        size: 20,
                                        color: Color(0xffF5F5F5),
                                      ),
                                      onPressed: () => toggleRunning(),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: Color(0xffF5F5F5),
                                      ),
                                      onPressed: () => deleteHost(context), // TODO dialog
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
