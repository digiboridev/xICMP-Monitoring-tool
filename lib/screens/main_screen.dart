import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';
import 'package:xicmpmt/screens/widgets/host_tile.dart';
import 'package:xicmpmt/screens/widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // MoveToBackground.moveTaskToBack();
        // TODO: implement onWillPop
        print('minimized');
        return false;
      },
      child: Scaffold(endDrawer: AppDrawer(), body: const HostsList()),
    );
  }
}

class HostsList extends StatefulWidget {
  const HostsList({super.key});

  @override
  State<HostsList> createState() => _HostsListState();
}

class _HostsListState extends State<HostsList> {
  final StatsRepository statsRepository = SL.statsRepository;
  final MonitoringService monitoringService = SL.monitoringService;

  List<Host> hosts = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    hosts = await statsRepository.getAllHosts();
    statsRepository.eventBus.where((event) => event is HostsUpdated).cast<HostsUpdated>().forEach((event) {
      setState(() => hosts = event.hosts);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(title: const Text('Monitoring hosts'), floating: true, pinned: false, snap: true),
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: _PinnedSliverDelegate(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  // TODO toltips
                  SizedBox(width: 8),
                  Text('Act', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 16),
                  Expanded(child: Text('Host', style: TextStyle(fontSize: 14))),
                  SizedBox(width: 16),
                  Text('Stats', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 32),
                  Text('Preview', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 38),
                  Text('More', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 16),
                ],
              ),
            ),
          ),
          // SliverAppBar(
          //   title: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: const [
          //       // TODO toltips
          //       SizedBox(width: 8),
          //       Text('Act', style: TextStyle(fontSize: 16)),
          //       SizedBox(width: 16),
          //       Expanded(child: Text('Host', style: TextStyle(fontSize: 16))),
          //       SizedBox(width: 16),
          //       Text('Stats', style: TextStyle(fontSize: 16)),
          //       SizedBox(width: 28),
          //       Text('Preview', style: TextStyle(fontSize: 16)),
          //       SizedBox(width: 50),
          //       Text('More', style: TextStyle(fontSize: 16)),
          //     ],
          //   ),
          //   floating: false,
          //   pinned: true,
          //   snap: false,
          //   automaticallyImplyLeading: false,
          //   actions: const [SizedBox.shrink()],
          //   toolbarHeight: 32,
          // ),
          for (var host in hosts) HostTile(host: host, key: Key(host.adress)),
        ],
      ),
    );
  }
}

class _PinnedSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _PinnedSliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final backColor = Theme.of(context).colorScheme.background;
    return SizedBox.expand(child: Container(color: backColor, child: child));
  }

  @override
  double get maxExtent => 32;

  @override
  double get minExtent => 32;

  @override
  bool shouldRebuild(covariant _PinnedSliverDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
