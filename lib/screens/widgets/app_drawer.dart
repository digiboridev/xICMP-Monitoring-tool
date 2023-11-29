import 'dart:ui';

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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Drawer(
        width: 250,
        backgroundColor: Colors.black.withOpacity(0.25),
        child: Column(
          children: [
            DrawerHeader(child: Center(child: Text('xICMP Monitoring Tool'))),
            Theme(
              data: Theme.of(context).copyWith(
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(onPressed: addDialog, child: const Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('Add host')])),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(onPressed: enableAll, child: const Row(children: [Icon(Icons.play_arrow), SizedBox(width: 8), Text('Enable all')])),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(onPressed: disableAll, child: const Row(children: [Icon(Icons.stop), SizedBox(width: 8), Text('Disable all')])),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          TextButton(onPressed: deleteAll, child: const Row(children: [Icon(Icons.delete_outlined), SizedBox(width: 8), Text('Delete all')])),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // TODO about
          ],
        ),
      ),
    );
  }
}
