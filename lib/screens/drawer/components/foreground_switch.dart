import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/utils/debouncer.dart';

class ForegroundSwitch extends StatefulWidget {
  const ForegroundSwitch({super.key});

  @override
  State<ForegroundSwitch> createState() => _ForegroundSwitchState();
}

class _ForegroundSwitchState extends State<ForegroundSwitch> {
  final settingsRepository = SL.settingsRepository;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  bool _foreground = false;

  @override
  void initState() {
    super.initState();
    settingsRepository.getSettings.then((value) => setState(() => _foreground = value.andWakeLock));
  }

  bool get foreground => _foreground;
  set foreground(bool v) {
    setState(() => _foreground = v);
    debouncer(() => settingsRepository.getSettings.then((settings) => settingsRepository.setSettings(settings.copyWith(andForeground: v))));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Text('Foreground service'),
          const SizedBox(width: 8),
          SizedBox(
            height: 28,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Switch(
                value: foreground,
                onChanged: (v) => foreground = v,
              ),
            ),
          ),
          const Spacer(),
          const Tooltip(
            message: 'Foreground service its an android mechanism to prevent app from being killed by system by showing a notification.',
            triggerMode: TooltipTriggerMode.tap,
            child: Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
    );
  }
}
