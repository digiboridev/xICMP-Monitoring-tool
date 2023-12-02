import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/utils/debouncer.dart';

class RecentSize extends StatefulWidget {
  const RecentSize({super.key});

  @override
  State<RecentSize> createState() => _RecentSizeState();
}

class _RecentSizeState extends State<RecentSize> {
  final settingsRepository = SL.settingsRepository;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  int _recentSize = 100;

  @override
  void initState() {
    super.initState();
    settingsRepository.getSettings.then((value) => setState(() => _recentSize = value.recentSize));
  }

  int get recentSize => _recentSize;
  set recentSize(int newSize) {
    setState(() => _recentSize = newSize);
    debouncer(() => settingsRepository.getSettings.then((settings) => settingsRepository.setSettings(settings.copyWith(recentSize: newSize))));
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
              Text('Recent size: ${recentSize} samples'),
              const Spacer(),
              const Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: 'Number of samples used to display preview stats',
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
              value: recentSize.toDouble(),
              min: 100,
              max: 1000,
              divisions: 9,
              label: '$recentSize',
              onChanged: (double value) => recentSize = value.toInt(),
            ),
          ),
        ],
      ),
    );
  }
}
