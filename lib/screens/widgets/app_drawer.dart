import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';
import 'package:xicmpmt/screens/widgets/host_adress_dialog.dart';
import 'package:xicmpmt/utils/fillable_scrollable_wrapper.dart';
import 'package:xicmpmt/utils/min_spacer.dart';

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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Theme(
        data: Theme.of(context).copyWith(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueGrey.shade900,
              backgroundColor: Colors.cyan.shade100,
            ),
          ),
        ),
        child: Drawer(
          width: 250,
          backgroundColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
          child: FillableScrollableWrapper(
            child: Column(
              children: [
                DrawerHeader(child: Center(child: Text('xICMP Monitoring Tool'))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextButton(onPressed: addDialog, child: const Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('Add host')])),
                        SizedBox(height: 16),
                        TextButton(onPressed: enableAll, child: const Row(children: [Icon(Icons.play_arrow), SizedBox(width: 8), Text('Enable all')])),
                        SizedBox(height: 16),
                        TextButton(onPressed: disableAll, child: const Row(children: [Icon(Icons.stop), SizedBox(width: 8), Text('Disable all')])),
                        SizedBox(height: 16),
                        TextButton(onPressed: deleteAll, child: const Row(children: [Icon(Icons.delete_outlined), SizedBox(width: 8), Text('Delete all')])),
                        // Spacer(),
                        MinSpacer(minHeight: 32),
                        TextButton(onPressed: () {}, child: const Row(children: [Icon(Icons.workspace_premium_outlined), SizedBox(width: 8), Text('About')])),
                        // TODO about
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
