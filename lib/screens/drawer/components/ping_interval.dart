import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/utils/debouncer.dart';

class PingInterval extends StatefulWidget {
  const PingInterval({super.key});

  @override
  State<PingInterval> createState() => _PingIntervalState();
}

class _PingIntervalState extends State<PingInterval> {
  final settingsRepository = SL.settingsRepository;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  Duration _pingInterval = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    settingsRepository.getSettings.then((value) => setState(() => _pingInterval = value.pingInterval));
  }

  Duration get pingInterval => _pingInterval;
  set pingInterval(Duration newInterval) {
    setState(() => _pingInterval = newInterval);
    debouncer(() => settingsRepository.getSettings.then((settings) => settingsRepository.setSettings(settings.copyWith(pingInterval: newInterval))));
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
              Text('Ping interval ${pingInterval.inMilliseconds} ms'),
              const Spacer(),
              const Tooltip(
                message: 'Pause between pings, pay attention to the battery consumption on short intervals',
                triggerMode: TooltipTriggerMode.tap,
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
              value: pingInterval.inMilliseconds.toDouble(),
              min: 100,
              max: 5000,
              divisions: 98,
              label: '${pingInterval.inMilliseconds}',
              onChanged: (double value) => pingInterval = Duration(milliseconds: value.toInt()),
            ),
          ),
        ],
      ),
    );
  }
}
