import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/utils/debouncer.dart';

class PingTimeout extends StatefulWidget {
  const PingTimeout({super.key});

  @override
  State<PingTimeout> createState() => _PingTimeoutState();
}

class _PingTimeoutState extends State<PingTimeout> {
  final settingsRepository = SL.settingsRepository;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  Duration _pingTimeout = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    settingsRepository.getSettings.then((value) => setState(() => _pingTimeout = value.pingTimeout));
  }

  Duration get pingTimeout => _pingTimeout;
  set pingTimeout(Duration newTimeout) {
    setState(() => _pingTimeout = newTimeout);
    debouncer(() => settingsRepository.getSettings.then((settings) => settingsRepository.setSettings(settings.copyWith(pingTimeout: newTimeout))));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Ping timeout ${pingTimeout.inMilliseconds} ms'),
              const Spacer(),
              const Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: 'Timeout for ping response, aslo max value for graph',
                child: Icon(Icons.info_outline_rounded),
              ),
            ],
          ),
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8, pressedElevation: 10),
            ),
            child: Slider(
              value: pingTimeout.inMilliseconds.toDouble(),
              min: 1000,
              max: 5000,
              divisions: 4,
              label: '${pingTimeout.inMilliseconds}',
              onChanged: (double value) => pingTimeout = Duration(milliseconds: value.toInt()),
            ),
          ),
        ],
      ),
    );
  }
}
