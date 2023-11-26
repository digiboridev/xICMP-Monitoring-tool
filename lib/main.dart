import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:xicmpmt/core/app_logger.dart';
import 'package:xicmpmt/data/drift/db.dart';
import 'package:xicmpmt/data/drift/tables/stats.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';

void main() {
  AppLogger.stream.listen((LogEntity l) {
    // Setup local log
    log(l.msg, time: l.time, error: l.error, stackTrace: l.stack, name: l.name, level: l.level.index);

    // Setup remote log
    // TODO: implement remote log
  });
  runApp(const PingStatsApp());
}

class PingStatsApp extends StatelessWidget {
  const PingStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PingStats',
      // theme: ThemeData.from(
      //   colorScheme: const ColorScheme(
      //     primary: Color(0xff000000),
      //     // primaryVariant: Color(0xff000000),
      //     secondary: Color(0xff000000),
      //     // secondaryVariant: Color(0xff000000),
      //     surface: Color(0xff09090B),
      //     background: Color(0xff121216),
      //     error: Color(0xffFAF338),
      //     onPrimary: Color(0xff000000),
      //     onSecondary: Color(0xff000000),
      //     onSurface: Color(0xff1C1C22),
      //     onBackground: Color(0xff000000),
      //     onError: Color(0xff000000),
      //     brightness: Brightness.dark,
      //   ),
      // ),
      // home: Provider(
      //   create: (_) => HostsDataBloc(),
      //   child: MainScreen(),
      // ),
      home: const MainScreen(),
    );
  }
}

MonitoringService monitoringService = MonitoringService(
  StatsRepositoryDriftImpl(StatsDao(DB())),
);

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PingStats'),
      ),
      body: Column(
        children: [
          Text('PingStats'),
          ElevatedButton(
            onPressed: () {
              monitoringService.startMonitoring();
            },
            child: const Text('Start'),
          ),
          ElevatedButton(
            onPressed: () {
              monitoringService.stopMonitoring();
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}
