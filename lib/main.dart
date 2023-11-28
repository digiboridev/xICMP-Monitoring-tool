// ignore_for_file: unused_import
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:xicmpmt/core/app_logger.dart';
import 'package:xicmpmt/screens/main_screen.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
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
      title: 'xICMP Monitoring Tool',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
