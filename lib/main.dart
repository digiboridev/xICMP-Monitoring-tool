// ignore_for_file: unused_import
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// import 'package:flutter/rendering.dart';
import 'package:xicmpmt/core/app_logger.dart';
import 'package:xicmpmt/screens/main_screen/main_screen.dart';

Future<void> main() async {
  // debugRepaintRainbowEnabled = true;

  AppLogger.stream.listen((LogEntity l) {
    // Setup local log
    log(l.msg, time: l.time, error: l.error, stackTrace: l.stack, name: l.name, level: l.level.index);

    // Setup remote log
    if (l.error != null) Sentry.captureException(l.error, stackTrace: l.stack);
    if (l.level == Level.info) Sentry.captureMessage(l.msg, template: l.name);
    final b = Breadcrumb(message: l.msg, level: SentryLevel.fromName(l.level.name), timestamp: l.time, category: l.name);
    Sentry.addBreadcrumb(b);
  });

  // runApp(const App());
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('sentryKey');
      options.tracesSampleRate = 1.0;
      options.enablePrintBreadcrumbs = false;
      options.enableAutoPerformanceTracing = true;
      // options.beforeSendTransaction = (transaction) async {
      //   debugPrint('tr send: ${transaction.eventId} ${DateTime.now()}');
      //   return transaction;
      // };
    },
    appRunner: () => runApp(const App()),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ColorScheme.fromSeed(
      seedColor: Color(0xff151820),
      brightness: Brightness.dark,
      surfaceTint: Color(0xff101216),
      primary: Colors.white,
      secondary: Colors.yellowAccent,
      background: Color(0xff101216),
    );

    return MaterialApp(
      title: 'xICMP Monitoring Tool',
      locale: Locale('en'),
      supportedLocales: const [Locale('en')],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: theme,
      ),
      home: const MainScreen(),
    );
  }
}


 //  TODO: md, policy, release.