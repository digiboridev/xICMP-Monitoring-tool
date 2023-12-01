// ignore_for_file: file_names
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';
import 'package:xicmpmt/core/formatters.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/ping.dart';
import 'package:xicmpmt/data/repositories/stats.dart';

class InteractiveGraph extends StatefulWidget {
  final String host;
  const InteractiveGraph({required this.host, super.key});

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
        if (scale == 1.0) loadData();
      });

      scr.addListener(() {
        if (!mounted) return;
        offset = scr.offset;
        setState(() {});
      });
    });
  }

  loadData() async {
    final rasterWidth = MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
    print('Raster width: $rasterWidth');

    final now = DateTime.now();
    from = now.subtract(selectedPeriod);
    to = now;

    final newData = await SL.statsRepository.hostPingsPeriodScaled(widget.host, from, to, (rasterWidth * 10).toInt());
    if (!mounted) return;

    print('loaded ${newData.length} points for $scale scale');
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
                IconButton(
                  onPressed: () => loadData(),
                  icon: const Icon(Icons.refresh, size: 20),
                ),
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

class GraphPainter extends CustomPainter {
  final List<Ping> dataSet;

  /// Start time of unscaled graph
  final DateTime start;

  /// End time of unscaled graph
  final DateTime end;

  /// View scale
  final double scale;

  /// View offset
  final double offset;

  /// Container width
  /// Unscaled painter width, note that size.width is scaled to be scrollable
  final double cWidth;

  /// Device pixel ratio
  final double pixelRatio;

  /// Maximum latency value, to limit graph height
  final int maxValue;

  GraphPainter(this.dataSet, this.scale, this.offset, this.cWidth, this.pixelRatio, this.start, this.end, {this.maxValue = 1000});

  static final Map<int, double> _heightCalcPool = {}; // Limited to maxValue
  static final LruMap<String, List<Offset>> _dLinePool = LruMap(maximumSize: 500000); // ~20mB

  @override
  void paint(Canvas canvas, Size size) {
    // debug
    final stopwatch = Stopwatch()..start();

    int first = start.millisecondsSinceEpoch;
    int last = end.millisecondsSinceEpoch;
    int timeDiff = last - first;

    double viewPortXStart = offset;
    double viewPortXEnd = offset + cWidth;

    int viewPortTimeStampStart = (last - timeDiff * (viewPortXStart / size.width)).toInt();
    int viewPortTimeStampEnd = (last - timeDiff * (viewPortXEnd / size.width)).toInt();

    double viewPortStartPercent = viewPortXStart / size.width;
    double viewPortEndPercent = viewPortXEnd / size.width;

    double viewPortRasterWidth = cWidth * pixelRatio;

    String viewPortKey = '$first$last${size.width}';

    // Calc canvas vertical position by value
    // 32 is top + bottom padding of dataset to avoid matrix scale
    double hCalcFunc(num value) {
      // Linear
      // double h = size.height - 32;
      // return (h / maxValue * (maxValue - value));

      // Exponential
      double scale = (value / maxValue).clamp(0, 1);
      scale = sqrt(scale);
      final invert = 1 - scale;
      return ((size.height - 32) * invert);
    }

    // Wrapper hCalc for caching results in a pool
    double hCalc(int v) => _heightCalcPool.putIfAbsent(v, () => hCalcFunc(v));

    // Calc canvas horizontal position by timestamp
    double wCalc(num time) {
      double timeDiffP = (last - time) / timeDiff;
      return size.width * timeDiffP;
    }

    //
    // Dataset drawing
    //

    Path dpath = Path();

    // Count of lines that will be drawn
    int viewPortCount = 0;

    // Function to calculate dataset polygon
    List<Offset> dLineFunc(int t, int v) {
      double x = wCalc(t);
      double ylow = size.height - 16;
      double yhigh = hCalc(v) + 16;

      Offset pointLow = Offset(x, ylow);
      Offset pointHigh = Offset(x, yhigh);

      return [pointLow, pointHigh];
    }

    // Wrapper dLineFunc to avoid recalculating on every frame by caching results in a pool
    // Has significant performance impact while scrolling by reducing
    // number of calculations for same points
    List<Offset> dLine(int t, int v) => _dLinePool.putIfAbsent('$t$v$viewPortKey', () => dLineFunc(t, v));

    for (var i = 0; i < dataSet.length; i++) {
      final p = dataSet[i];
      final timeStamp = p.time.millisecondsSinceEpoch;
      if (timeStamp > viewPortTimeStampStart || timeStamp < viewPortTimeStampEnd) continue;
      final value = p.latency;

      dpath.addPolygon(dLine(timeStamp, value), true);
      viewPortCount++;
    }

    // Provide stacking on many points per pixel,
    // so it can be recognizes as gradient of intensity rather then mess of lines
    double opacityByCount() {
      double intensityFactor = (viewPortRasterWidth / viewPortCount).clamp(0, 1);
      // double expo = sqrt(intensityFactor).toDouble();
      return intensityFactor;
    }

    canvas.drawPath(
      dpath,
      Paint()
        // ..color = Color(0xffFAF338).withOpacity(opacityByCount())
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.8, 1],
          colors: [
            Colors.yellowAccent.withOpacity(opacityByCount()),
            Colors.yellowAccent.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke,
    );

    //
    // Vertical grid with values drawing
    //

    Path vpath = Path();

    final vas = maxValue ~/ 10;

    for (var i = 0; i < 11; i++) {
      TextSpan span = TextSpan(
        style: TextStyle(
          color: Color(0xffF5F5F5),
          fontSize: 6,
          fontWeight: FontWeight.w200,
          height: 1,
          shadows: const [
            Shadow(blurRadius: 2, color: Colors.black54),
            Shadow(blurRadius: 8, color: Colors.black54),
          ],
        ),
        text: '${i * vas}',
      );
      TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);

      tp.layout();
      final twidth = tp.size.width;
      final theight = tp.size.height;

      final y = hCalc(i * vas) + 16;
      final texty = y - theight / 2;

      // Draw data mesh lines
      vpath.moveTo(viewPortXStart, y);
      vpath.lineTo(viewPortXEnd, y);

      // Draw data mesh text
      tp.paint(canvas, Offset(viewPortXStart, texty));
      tp.paint(canvas, Offset((viewPortXEnd) - twidth, texty));
    }

    canvas.drawPath(
      vpath,
      Paint()
        ..color = Colors.white10
        ..style = PaintingStyle.stroke,
    );

    //
    // Horizontal grid with time points drawing
    //

    Path hpath = Path();

    for (double i = 0; i < 0.99; i += (1 / (scale.floor() * 10))) {
      if (viewPortStartPercent < i && viewPortEndPercent > i) {
        double timeNum = last - timeDiff * i;
        DateTime time = DateTime.fromMillisecondsSinceEpoch(timeNum.toInt());

        Duration viewTimeDiff =
            DateTime.fromMillisecondsSinceEpoch(viewPortTimeStampStart).difference(DateTime.fromMillisecondsSinceEpoch(viewPortTimeStampEnd));

        String timeText = '';
        if (viewTimeDiff < Duration(hours: 1)) {
          timeText = time.numms;
        } else if (viewTimeDiff < Duration(days: 2)) {
          timeText = time.numhm;
        } else {
          timeText = time.numdm;
        }

        TextSpan span = TextSpan(style: TextStyle(color: Color(0xffF5F5F5), fontSize: 10, fontWeight: FontWeight.w200), text: timeText);
        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
        tp.layout();

        final twidth = tp.size.width;
        final theight = tp.size.height;

        // Draw time text
        tp.paint(canvas, Offset(size.width * i - twidth / 2, size.height - theight));

        // Draw top line over dataset
        hpath.moveTo(size.width * i, 0);
        hpath.lineTo(size.width * i, 16 - theight);

        // Draw bottom line over time text
        hpath.moveTo(size.width * i, size.height - 16);
        hpath.lineTo(size.width * i, size.height - theight);
      }
    }

    canvas.drawPath(
      hpath,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke,
    );

    // debug
    stopwatch.stop();
    print('GraphPainter $viewPortCount points in ${stopwatch.elapsedMicroseconds}us');
    print('heightCalcPool: ${_heightCalcPool.length}');
    print('dLinePool: ${_dLinePool.length}');
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.cWidth != cWidth ||
        start != oldDelegate.start ||
        end != oldDelegate.end ||
        !listEquals(dataSet, oldDelegate.dataSet);
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
