import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/utils/debouncer.dart';

class RasterScale extends StatefulWidget {
  const RasterScale({super.key});

  @override
  State<RasterScale> createState() => _RasterScaleState();
}

class _RasterScaleState extends State<RasterScale> {
  final settingsRepository = SL.settingsRepository;
  final debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  int _rasterScale = 10;

  @override
  void initState() {
    super.initState();
    settingsRepository.getSettings.then((value) => setState(() => _rasterScale = value.rasterScale));
  }

  int get rasterScale => _rasterScale;
  set rasterScale(int newScale) {
    setState(() => _rasterScale = newScale);
    debouncer(() => settingsRepository.getSettings.then((settings) => settingsRepository.setSettings(settings.copyWith(rasterScale: newScale))));
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
              Text('Raster scale: $rasterScale x'),
              const Spacer(),
              const Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: 'Number of samples per pixel used to display detailed graph',
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
              value: rasterScale.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: '$rasterScale',
              onChanged: (double value) => rasterScale = value.toInt(),
            ),
          ),
        ],
      ),
    );
  }
}
