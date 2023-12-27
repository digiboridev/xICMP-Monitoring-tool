// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xicmpmt/core/app_logger.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/models/ping.dart';
import 'package:xicmpmt/data/repositories/settings.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';
import 'package:xicmpmt/screens/main_screen/components/interactive_graph.dart';
import 'package:xicmpmt/screens/main_screen/components/blinking_circle.dart';
import 'package:xicmpmt/screens/main_screen/components/preview_histogram.dart';
import 'package:xicmpmt/screens/main_screen/components/recent_stats.dart';
import 'package:xicmpmt/utils/to_csv.dart';

class HostTile extends StatefulWidget {
  final Host host;
  const HostTile({required this.host, super.key});

  @override
  State<HostTile> createState() => _HostTileState();
}

class _HostTileState extends State<HostTile> {
  final SettingsRepository settingsRepository = SL.settingsRepository;
  final StatsRepository statsRepository = SL.statsRepository;
  final MonitoringService monitoringService = SL.monitoringService;

  int recentSize = 150;
  int rasterScale = 10;
  bool expanded = false;

  void toggleRunning() {
    statsRepository.updateHost(widget.host.copyWith(enabled: !widget.host.enabled));
    monitoringService.upsertMonitoring();
    AppLogger.debug('toggle running ${widget.host.adress}', name: 'HostTile');
  }

  void deleteHost(BuildContext context) {
    statsRepository.deleteHost(widget.host.adress);
    monitoringService.upsertMonitoring();
    AppLogger.debug('delete host ${widget.host.adress}', name: 'HostTile');
  }

  exportData() async {
    List<Ping> data = await statsRepository.hostPings(widget.host.adress);
    AppLogger.debug('export data ${widget.host.adress} ${data.length}', name: 'HostTile');

    List<String> header = ['host', 'time', 'latency ms', 'lost'];
    List<List<String>> rows = data.map((e) => [e.host, e.time.toString(), e.latency.toString(), e.lost.toString()]).toList();

    try {
      final filename = await toCSV(widget.host.adress, header, rows);
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text('Saved to $filename'),
          // backgroundColor: AppColors.cyan400,
          actions: [
            TextButton(
              onPressed: () => launchUrl(Uri.parse('content://$filename')),
              child: const Text('Open'),
            ),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e, s) {
      debugPrint(e.toString());
      AppLogger.error('Error: $e', error: e, stack: s);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  void initState() {
    super.initState();

    settingsRepository.getSettings.then((settings) {
      if (!mounted) return;
      recentSize = settings.recentSize;
      rasterScale = settings.rasterScale;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPersistentHeader(
          pinned: true,
          floating: false,
          delegate: _PinnedSliverDelegate(
            child: RepaintBoundary(
              child: Row(
                children: [
                  SizedBox(width: 4),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => expanded = !expanded),
                          child: Opacity(
                            opacity: widget.host.enabled ? 1 : 0.5,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 8),
                                StreamBuilder(
                                  stream: statsRepository.eventBus.where((event) => event is PingAdded && event.ping.host == widget.host.adress),
                                  builder: (context, snapshot) => BlinkingCircle(),
                                ),
                                SizedBox(width: 16),
                                Expanded(child: Text(widget.host.adress, style: TextStyle(fontSize: 16), overflow: TextOverflow.fade, softWrap: false)),
                                SizedBox(width: 16),
                                SizedBox(width: 70, child: RecentStats(host: widget.host.adress, size: recentSize)),
                                SizedBox(width: 70, height: 32, child: PreviewHistorgam(host: widget.host.adress, size: recentSize)),
                                SizedBox(width: 4),
                                Icon(!expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                                SizedBox(width: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(width: 8),
                  menuButton(),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: AnimatedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: expanded ? 250 : 0,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutExpo,
              child: OverflowBox(
                maxHeight: 250,
                child: expanded ? InteractiveGraph(host: widget.host.adress, rasterScale: rasterScale) : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget menuButton() {
    return Container(
      width: 28,
      height: 28,
      margin: EdgeInsets.only(right: 16),
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_horiz),
        itemBuilder: (context) => [
          widget.host.enabled ? PopupMenuItem(value: 'toggle', child: Text('Disable')) : PopupMenuItem(value: 'toggle', child: Text('Enable')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
          PopupMenuItem(value: 'export', child: Text('Export')),
        ],
        onSelected: (value) {
          if (value == 'toggle') toggleRunning();
          if (value == 'delete') deleteHost(context);
          if (value == 'export') exportData();
        },
      ),
    );
  }
}

class _PinnedSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _PinnedSliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _PinnedSliverDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
