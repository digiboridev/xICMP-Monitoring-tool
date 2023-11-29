// ignore_for_file: file_names
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  double prevMaxScale = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
      scr.addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          offset = scr.offset;
          setState(() {});
        });
      });
    });
  }

  loadData({bool force = false}) async {
    final rasterWidth = MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
    if (force) {
      final now = DateTime.now();
      from = now.subtract(selectedPeriod);
      to = now;

      final newData = await SL.statsRepository.getPingsForHostPeriodScale(widget.host, from, to, (rasterWidth * 10 * scale).toInt());
      if (!mounted) return;

      print('loaded ${newData.length} points for $scale scale, forced');
      data = newData;
      setState(() => {});
    } else {
      if (scale < prevMaxScale) return;
      final newData = await SL.statsRepository.getPingsForHostPeriodScale(widget.host, from, to, (rasterWidth * 10 * scale).toInt());
      if (!mounted) return;

      print('loaded ${newData.length} points for $scale scale');
      prevMaxScale = scale;
      data = newData;
      setState(() => {});
    }
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
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
                    GestureDetector(
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
                      onScaleEnd: (details) => loadData(),
                      behavior: HitTestBehavior.translucent,
                      child: Container(),
                    ),
                  ],
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
                // Text('Period: ', style: TextStyle(color: Color(0xffF5F5F5), fontSize: 12, fontWeight: FontWeight.w400)),
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
                        final now = DateTime.now();
                        selectedPeriod = newValue;
                        from = now.subtract(selectedPeriod);
                        to = now;
                        scale = 1.0;
                        prevMaxScale = 0;
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
                  onPressed: () {
                    loadData(force: true);
                  },
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
                    loadData();
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
                    loadData();
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
  final Iterable<Ping> dataSet;
  final DateTime start;
  final DateTime end;

  // Widget width scale
  double scale;

  // Scroll controller or scrollview
  // Uses for position calculations
  double offset;

  // Container width
  // Unscaled painter width, note that size.width is scaled to be scrollable
  double cWidth;

  double pixelRatio;

  GraphPainter(this.dataSet, this.scale, this.offset, this.cWidth, this.pixelRatio, this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    // debug
    final stopwatch = Stopwatch()..start();

    // Main time values
    // Needs for scaling and positioning point on canvas
    int first = start.millisecondsSinceEpoch;
    int last = end.millisecondsSinceEpoch;
    int timeDiff = last - first;
    int viewPortTimeStampStart = (last - timeDiff * (offset / size.width)).toInt();
    int viewPortTimeStampEnd = (last - timeDiff * ((offset + cWidth) / size.width)).toInt();
    double viewPortRasterWidth = cWidth * pixelRatio;

    // Calc percent of canvas height by point ping
    double hCalc(num p) {
      double h = size.height - 32;
      return (h / 1000 * (1000 - p));
    }

    // Calc percent of canvas width by point time
    double wCalc(num time) {
      double timeDiffP = ((last - time) / timeDiff);
      return size.width * timeDiffP;
    }

    // Init pathes
    Path pingLine = Path();
    Path times = Path();

    for (var i = 0; i < 6; i++) {
      TextSpan span = TextSpan(
        style: TextStyle(
          color: Color(0xffF5F5F5),
          fontSize: 6,
          fontWeight: FontWeight.w200,
          height: 1,
          shadows: const [
            Shadow(blurRadius: 2, color: Colors.black),
            Shadow(blurRadius: 8, color: Colors.black),
          ],
        ),
        text: '${i * 200}',
      );
      TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);

      tp.layout();
      final twidth = tp.size.width;
      final theight = tp.size.height;

      tp.paint(canvas, Offset(offset, hCalc(i * 200) + 16 + theight / 2));
      tp.paint(canvas, Offset((offset + cWidth) - twidth, hCalc(i * 200) + 16 + theight / 2));
    }

    for (double i = 0; i < 0.99; i += (1 / (scale.floor() * 10))) {
      // Cut other optimization
      if ((offset) / size.width < i && (offset + cWidth) / size.width > i) {
        // Calc time by percent of with
        double timeNum = last - timeDiff * i;
        DateTime time = DateTime.fromMillisecondsSinceEpoch(timeNum.toInt());

        // Draw text with time
        TextSpan span = TextSpan(style: TextStyle(color: Color(0xffF5F5F5), fontSize: 10, fontWeight: FontWeight.w200), text: '${time.hour}:${time.minute}');
        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
        tp.layout();
        final twidth = tp.size.width;
        final theight = tp.size.height;
        tp.paint(canvas, Offset(size.width * i, size.height - theight));

        // Draw little points that uses as scale points
        times.moveTo(size.width * i + twidth / 2, 8);
        times.lineTo(size.width * i + twidth / 2, 16);
      }
    }

    int count = 0;

    for (var i = 0; i < dataSet.length; i++) {
      final p = dataSet.elementAt(i);
      final timeStamp = p.time.millisecondsSinceEpoch;
      if (timeStamp > viewPortTimeStampStart || timeStamp < viewPortTimeStampEnd) continue;

      double time = wCalc(timeStamp);
      int ping = p.latency;

      pingLine.moveTo((time), size.height - 16);
      pingLine.lineTo((time), hCalc(ping) + 16);
      count++;
    }

    // Provide stacking on many points per pixel,
    // so it can be recognizes as gradient of intensity rather then mess of lines
    double opacityByCount() {
      double intensityFactor = (1 / (count / viewPortRasterWidth)).clamp(0, 1);
      // double expo = sqrt(intensityFactor).toDouble();
      return intensityFactor;
    }

    canvas.drawPath(
      pingLine,
      Paint()
        ..color = Color(0xffFAF338).withOpacity(opacityByCount())
        // ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    canvas.drawPath(
      times,
      Paint()
        ..color = Color(0xffF5F5F5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    // debug
    stopwatch.stop();
    print('GraphPainter $count points in ${stopwatch.elapsedMicroseconds}us');
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.cWidth != cWidth ||
        start != oldDelegate.start ||
        end != oldDelegate.end ||
        oldDelegate.dataSet != dataSet;
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
