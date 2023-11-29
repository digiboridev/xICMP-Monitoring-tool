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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          title: const Text('Monitoring hosts'),
          floating: true,
          pinned: false,
          snap: true,
        ),
        SliverAppBar(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                // TODO toltips
                SizedBox(width: 8),
                Text('Act', style: TextStyle(fontSize: 16)),
                SizedBox(width: 16),
                Expanded(child: Text('Host', style: TextStyle(fontSize: 16))),
                SizedBox(width: 16),
                Text('Stats', style: TextStyle(fontSize: 16)),
                SizedBox(width: 28),
                Text('Preview', style: TextStyle(fontSize: 16)),
                SizedBox(width: 42),
                Text('More', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
              ],
            ),
          ),
          floating: false,
          pinned: true,
          snap: false,
          automaticallyImplyLeading: false,
          actions: const [SizedBox.shrink()],
        ),
        for (var host in hosts) HostTile(host: host, key: Key(host.adress)),
      ],
    );
  }
}
