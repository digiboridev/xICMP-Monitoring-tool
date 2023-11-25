import 'package:flutter/material.dart';

void main() {
  runApp(const PingStatsApp());
}

class PingStatsApp extends StatelessWidget {
  const PingStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PingStats',
      theme: ThemeData.from(
        colorScheme: const ColorScheme(
          primary: Color(0xff000000),
          // primaryVariant: Color(0xff000000),
          secondary: Color(0xff000000),
          // secondaryVariant: Color(0xff000000),
          surface: Color(0xff09090B),
          background: Color(0xff121216),
          error: Color(0xffFAF338),
          onPrimary: Color(0xff000000),
          onSecondary: Color(0xff000000),
          onSurface: Color(0xff1C1C22),
          onBackground: Color(0xff000000),
          onError: Color(0xff000000),
          brightness: Brightness.dark,
        ),
      ),
      // home: Provider(
      //   create: (_) => HostsDataBloc(),
      //   child: MainScreen(),
      // ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PingStats'),
      ),
      body: const Center(
        child: Text('PingStats'),
      ),
    );
  }
}
