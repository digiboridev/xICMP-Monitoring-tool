import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xICMP_Monitoring_tool/repository/bloc/HostsDataBloc.dart';
import 'package:xICMP_Monitoring_tool/screens/MainScreen.dart';

void main() {
  runApp(PingStatsApp());
}

class PingStatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PingStats',
        theme: ThemeData.from(
            colorScheme: ColorScheme(
                primary: Color(0xff000000),
                primaryVariant: Color(0xff000000),
                secondary: Color(0xff000000),
                secondaryVariant: Color(0xff000000),
                surface: Color(0xff09090B),
                background: Color(0xff121216),
                error: Color(0xffFAF338),
                onPrimary: Color(0xff000000),
                onSecondary: Color(0xff000000),
                onSurface: Color(0xff1C1C22),
                onBackground: Color(0xff000000),
                onError: Color(0xff000000),
                brightness: Brightness.dark)),
        home: Provider(create: (_) => HostsDataBloc(), child: MainScreen()));
  }
}

// Color palette
// https://coolors.co/f5f5f5-1c1c22-db5762-faf338
