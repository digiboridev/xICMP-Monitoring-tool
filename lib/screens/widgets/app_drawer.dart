import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';
import 'package:xicmpmt/screens/widgets/host_adress_dialog.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final StatsRepository statsRepository = SL.statsRepository;
  final MonitoringService monitoringService = SL.monitoringService;

  void enableAll() async {
    await statsRepository.enableAllHosts();
    monitoringService.upsertMonitoring();
  }

  void disableAll() async {
    await statsRepository.disableAllHosts();
    monitoringService.upsertMonitoring();
  }

  void addDialog() async {
    String? newHost = await showDialog(context: context, builder: (_) => const HostAdressDialog(hostAdress: ''));
    if (newHost != null) statsRepository.addHost(Host(adress: newHost, enabled: true));
    monitoringService.upsertMonitoring();
  }

  void deleteAll() async {
    await statsRepository.deleteAllHosts();
    monitoringService.upsertMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Container(
          //   height: 100,
          //   child: DrawerHeader(child: Center(child: Text('PingStats v 1.0'))),
          // ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              children: [
                TextButton(onPressed: addDialog, child: const Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('Add host')])),
                SizedBox(height: 8),
                TextButton(onPressed: enableAll, child: const Row(children: [Icon(Icons.play_arrow), SizedBox(width: 8), Text('Enable all')])),
                SizedBox(height: 8),
                TextButton(onPressed: disableAll, child: const Row(children: [Icon(Icons.stop), SizedBox(width: 8), Text('Disable all')])),
                SizedBox(height: 8),
                TextButton(onPressed: deleteAll, child: const Row(children: [Icon(Icons.delete_outlined), SizedBox(width: 8), Text('Delete all')])),
                SizedBox(height: 8),
                // TODO minimize
                TextButton(onPressed: () {}, child: const Row(children: [Icon(Icons.minimize), SizedBox(width: 8), Text('Minimize')])),
                SizedBox(height: 8),
                TextButton(onPressed: () async => exit(0), child: const Row(children: [Icon(Icons.minimize), SizedBox(width: 8), Text('Close app')])),
                SizedBox(height: 8),
              ],
            ),
          ),
          // TODO about
        ],
      ),
    );
  }
}
