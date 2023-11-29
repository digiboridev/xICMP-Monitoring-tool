import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';
import 'package:xicmpmt/screens/widgets/interactive_graph.dart';
import 'package:xicmpmt/screens/widgets/blinking_circle.dart';
import 'package:xicmpmt/screens/widgets/preview_histogram.dart';
import 'package:xicmpmt/screens/widgets/recent_stats.dart';

class HostTile extends StatefulWidget {
  final Host host;
  const HostTile({required this.host, super.key});

  @override
  State<HostTile> createState() => _HostTileState();
}

class _HostTileState extends State<HostTile> {
  final StatsRepository statsRepository = SL.statsRepository;
  final MonitoringService monitoringService = SL.monitoringService;

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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
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
                  Expanded(child: Text(widget.host.adress, overflow: TextOverflow.fade, softWrap: false)),
                  SizedBox(width: 16),
                  SizedBox(width: 70, child: RecentStats(host: widget.host.adress, size: 150)),
                  SizedBox(width: 70, height: 24, child: PreviewHistorgam(host: widget.host.adress, size: 150)),
                  SizedBox(width: 8),
                  Icon(!expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                  SizedBox(height: 32, child: menuButton()),
                ],
              ),
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedContainer(
            height: expanded ? 250 : 0,
            duration: Duration(milliseconds: 600),
            curve: expanded ? Curves.bounceOut : Curves.easeOutExpo,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInExpo,
              opacity: expanded ? 1 : 0,
              child: OverflowBox(
                maxHeight: 250,
                child: expanded ? InteractiveGraph(host: widget.host.adress) : null,
              ),
            ),
          ),
        ),
        // SizedBox(height: 12),
      ],
    );
  }

  Widget menuButton() {
    return PopupMenuButton(
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
        // TODO: implement export
      },
    );
  }
}
