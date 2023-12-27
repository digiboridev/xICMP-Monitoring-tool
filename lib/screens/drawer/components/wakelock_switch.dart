import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/utils/debouncer.dart';

class WakelockSwitch extends StatefulWidget {
  const WakelockSwitch({super.key});

  @override
  State<WakelockSwitch> createState() => _WakelockSwitchState();
}

class _WakelockSwitchState extends State<WakelockSwitch> {
  final settingsRepository = SL.settingsRepository;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  bool _wakelock = false;

  @override
  void initState() {
    super.initState();
    settingsRepository.getSettings.then((value) => setState(() => _wakelock = value.andWakeLock));
  }

  bool get wakelock => _wakelock;
  set wakelock(bool v) {
    setState(() => _wakelock = v);
    debouncer(() => settingsRepository.getSettings.then((settings) => settingsRepository.setSettings(settings.copyWith(andWakeLock: v))));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Text('CPU Wakelock'),
          const SizedBox(width: 8),
          SizedBox(
            height: 28,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Switch(
                value: wakelock,
                onChanged: (v) => wakelock = v,
              ),
            ),
          ),
          const Spacer(),
          const Tooltip(
            message:
                'Wakelock keeps CPU awake while sampling is running. It prevents app trottling by system, when screen is off. It may drain battery faster.',
            triggerMode: TooltipTriggerMode.tap,
            child: Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
    );
  }
}
