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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitoring hosts'),
        ),
        endDrawer: AppDrawer(),
        body: const HostsList(),
      ),
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
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Status'),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Host'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Latency'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              margin: const EdgeInsets.only(right: 32),
              child: const Text('Preview'),
            ),
          ],
        ),
        const Divider(),
        for (var host in hosts) HostTile(host: host),
      ],
    );
  }
}
