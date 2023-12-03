import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xicmpmt/core/app_logger.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/ping.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/screens/main_screen/components/interactive_graph_painter.dart';

class InteractiveGraph extends StatefulWidget {
  final String host;
  final int rasterScale;
  const InteractiveGraph({required this.host, required this.rasterScale, super.key});

  @override
  State<InteractiveGraph> createState() => _InteractiveGraphState();
}

class _InteractiveGraphState extends State<InteractiveGraph> {
  final StatsRepository statsRepository = SL.statsRepository;
  final ScrollController scr = ScrollController();

  List<Ping> data = [];

  // Period of time to show
  late Duration selectedPeriod = Duration(minutes: 15);
  late DateTime from = DateTime.now().subtract(selectedPeriod);
  late DateTime to = DateTime.now();

  //Uses for make graph zoomable
  double scale = 1.0;
  double offset = 0;

  // Uses to zoom and scroll calculations
  double prevscale = 1.0;
  double prevOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();

      // Auto update data every 5 seconds
      // Only if graph is not zoomed, to avoid drift on detailed view
      Timer.periodic(Duration(seconds: 5), (timer) {
        if (!mounted) return timer.cancel();
        if (scale == 1.0 && selectedPeriod.inHours < 1) loadData();
      });

      // Update graph on scroll
      // Uses by painter to draw only visible part of graph
      scr.addListener(() {
        if (!mounted) return;
        offset = scr.offset;
        setState(() {});
      });
    });
  }

  loadData() async {
    final rasterWidth = MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
    AppLogger.debug('Raster width: $rasterWidth', name: 'InteractiveGraph');
    AppLogger.debug('Raster scale: ${widget.rasterScale}', name: 'InteractiveGraph');

    final now = DateTime.now();
    from = now.subtract(selectedPeriod);
    to = now;

    final newData = await SL.statsRepository.hostPingsPeriodScaled(widget.host, from, to, (rasterWidth * widget.rasterScale).toInt());
    if (!mounted) return;

    AppLogger.debug('loaded ${newData.length} points for $scale scale', name: 'InteractiveGraph');
    data = newData;
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constrains) {
              final width = constrains.maxWidth;
              final height = constrains.maxHeight;
              return SizedBox(
                width: width,
                height: height,
                child: GestureDetector(
                  onScaleStart: (details) {
                    prevOffset = scr.offset;
                    prevscale = scale;
                  },
                  // Adjust new scale loocking on previous values
                  onScaleUpdate: (details) {
                    setState(() {
                      // Adjust scale
                      scale = prevscale * details.scale;
                      if (scale < 1.0) scale = 1.0;
                      // Adjust offset
                      final newOffset = prevOffset * details.scale + details.focalPoint.dx * (details.scale - 1);
                      // Jump to offset proportionaly to scale
                      if (scale > 1.0) {
                        scr.jumpTo(newOffset);
                        offset = newOffset;
                      }
                    });
                  },

                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    controller: scr,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    dragStartBehavior: DragStartBehavior.down,
                    child: SizedBox(
                      // Grow conteiner width depend on scale value
                      width: width * scale,
                      child: CustomPaint(
                        willChange: true,
                        isComplex: true,
                        painter: GraphPainter(data, scale, offset, width, MediaQuery.of(context).devicePixelRatio, from, to),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        LayoutBuilder(
          builder: (context, constrains) {
            final width = constrains.maxWidth;
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white54, width: 1),
                    // color: Color(0xffF5F5F5),
                  ),
                  child: DropdownButton<Duration>(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    isDense: true,
                    isExpanded: false,
                    value: selectedPeriod,
                    alignment: AlignmentDirectional.center,
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    onChanged: (Duration? newValue) {
                      if (newValue == null) return;
                      setState(() {
                        selectedPeriod = newValue;
                        scale = 1.0;
                        offset = 0;
                        scr.jumpTo(0);
                        loadData();
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    style: TextStyle(fontSize: 12),
                    underline: SizedBox.shrink(),
                    items: periodDropdownList,
                  ),
                ),
                // IconButton(
                //   onPressed: () => loadData(),
                //   icon: const Icon(Icons.refresh, size: 20),
                // ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    if (scale == 1.0) return;
                    scr.animateTo(
                      offset - (width / 10),
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.keyboard_double_arrow_left_outlined, size: 20),
                ),
                IconButton(
                  onPressed: () {
                    if (scale == 1.0) return;
                    scr.animateTo(
                      offset + (width / 10),
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.keyboard_double_arrow_right_outlined, size: 20),
                ),
                IconButton(
                  onPressed: () {
                    scale = scale * 1.1;
                    if (scale < 1.0) scale = 1.0;
                    offset = offset * 1.1 + width * 0.1 / 2;
                    if (scale == 1.0) offset = 0;
                    scr.jumpTo(offset);
                    setState(() {});
                    // loadData();
                  },
                  icon: const Icon(Icons.zoom_in, size: 20),
                ),
                IconButton(
                  onPressed: () {
                    scale = scale / 1.1;
                    if (scale < 1.0) scale = 1.0;
                    offset = offset / 1.1 - width * 0.1 / 2.2;
                    if (scale == 1.0) offset = 0;
                    scr.jumpTo(offset);
                    setState(() {});
                    // loadData();
                  },
                  icon: const Icon(Icons.zoom_out, size: 20),
                ),
                IconButton(
                  onPressed: () {
                    offset = 0;
                    scale = 1;
                    setState(() {});
                  },
                  icon: const Icon(Icons.settings_backup_restore_rounded, size: 20),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

List<DropdownMenuItem<Duration>> periodDropdownList = [
  DropdownMenuItem(
    value: Duration(minutes: 15),
    child: Text('15 min'),
  ),
  DropdownMenuItem(
    value: Duration(hours: 1),
    child: Text('1 hour'),
  ),
  DropdownMenuItem(
    value: Duration(hours: 6),
    child: Text('6 hours'),
  ),
  DropdownMenuItem(
    value: Duration(hours: 12),
    child: Text('12 hours'),
  ),
  DropdownMenuItem(
    value: Duration(days: 1),
    child: Text('1 day'),
  ),
  DropdownMenuItem(
    value: Duration(days: 3),
    child: Text('3 days'),
  ),
  DropdownMenuItem(
    value: Duration(days: 7),
    child: Text('Week'),
  ),
];
