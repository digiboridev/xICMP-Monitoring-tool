import 'dart:math';

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

  List<Ping> data = [];

  //Init scale value
  //Uses for make graph zoomable
  double scale = 1.0;

  //Uses to zoom and scroll calculations
  double prevscale = 1.0;
  double prevOffset = 0;

  ScrollController scr = ScrollController();

  Duration selectedPeriod = Duration(hours: 3);
  List<DropdownMenuItem<Duration>> periodDropdownList = [
    DropdownMenuItem(
      value: Duration(minutes: 5),
      child: Text('30 mins'),
    ),
    DropdownMenuItem(
      value: Duration(hours: 3),
      child: Text('3 Hours'),
    ),
    DropdownMenuItem(
      value: Duration(hours: 6),
      child: Text('6 Hours'),
    ),
    DropdownMenuItem(
      value: Duration(hours: 12),
      child: Text('12 Hours'),
    ),
    DropdownMenuItem(
      value: Duration(days: 1),
      child: Text('1 day'),
    ),
    DropdownMenuItem(
      value: Duration(days: 3),
      child: Text('3 Days'),
    ),
    DropdownMenuItem(
      value: Duration(days: 7),
      child: Text('Week'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    final now = DateTime.now();
    final d = await SL.statsRepository.getPingsForHostPeriod(widget.host, now.subtract(selectedPeriod), now);
    if (!mounted) return;
    setState(() => data = d);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              // Some times canvas may draws over container
              // Hard clip it
              child: SingleChildScrollView(
                controller: scr,
                scrollDirection: Axis.horizontal,
                // Detects scale gesture
                child: GestureDetector(
                  // Hold last values before changes
                  onScaleStart: (details) {
                    prevOffset = scr.offset;
                    prevscale = scale;
                  },

                  // Adjust new scale loocking on previous values
                  onScaleUpdate: (details) {
                    setState(() {
                      // Jump to offset proportionaly to scale
                      double asd = prevOffset * details.scale;
                      scr.jumpTo(asd);

                      // Adjust scale
                      scale = prevscale * details.scale;
                      scale < 1.0 ? scale = 1 : scale = scale;
                    });
                  },
                  child: SizedBox(
                    // Grow conteiner width depend on scale value
                    width: (MediaQuery.of(context).size.width - 32) * scale,
                    child: CustomPaint(
                      painter: GraphPainter(data, scale, scr, (MediaQuery.of(context).size.width - 32)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Text('Show: ', style: TextStyle(color: Color(0xffF5F5F5), fontSize: 12, fontWeight: FontWeight.w400)),
            DropdownButton(
              value: selectedPeriod,
              onChanged: (Duration? newValue) {
                if (newValue == null) return;
                setState(() {
                  selectedPeriod = newValue;
                  loadData();
                });
                FocusScope.of(context).unfocus();
              },
              style: TextStyle(color: Color(0xffF5F5F5), fontSize: 12, fontWeight: FontWeight.w400),
              underline: SizedBox.shrink(),
              items: periodDropdownList,
            ),
          ],
        ),
      ],
    );
  }
}

class GraphPainter extends CustomPainter {
  Iterable<Ping> xList = [];

  // Widget width scale
  double scale;

  // Scroll controller or scrollview
  // Uses for position calculations
  ScrollController scr;

  // Container width
  // Uses for vievport calculations
  double cWidth;

  GraphPainter(this.xList, this.scale, this.scr, this.cWidth);

  @override
  void paint(Canvas canvas, Size size) {
    // Main time values
    // Needs for scaling and positioning point on canvas
    int first = xList.first.time.millisecondsSinceEpoch;
    int last = xList.last.time.millisecondsSinceEpoch;
    int timeDiff = last - first;

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

    for (var i = 0; i < 5; i++) {
      TextSpan span = TextSpan(style: TextStyle(color: Color(0xffF5F5F5), fontSize: 6, fontWeight: FontWeight.w200), text: '${i * 200}');

      TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);

      tp.layout();
      tp.paint(canvas, Offset(0, hCalc(i * 200)));
      tp.paint(canvas, Offset(size.width - 8, hCalc(i * 200)));
    }

    // Count of drawing point
    // For perfomance debug
    int count = 0;

    // Stopwatch stopwatch = new Stopwatch()..start();

    // Drawing loop for ping points

    // Cut outer of screen points fir optimizations
    // Uses scroll offset from parent to calc it
    List<Ping> cutedList = [];

    for (var i = 0; i < xList.length; i++) {
      final p = xList.elementAt(i);
      double time = wCalc(p.time.millisecondsSinceEpoch);
      if (time > scr.offset && time < scr.offset + cWidth) {
        cutedList.add(p);
      }
    }

    // Percent of points for optimizations
    // Last value regulate how many points will display on canvas
    // double pWidth = cutedList.length / 9000;

    for (var i = 0; i < cutedList.length; i++) {
      final p = xList.elementAt(i);

      double time = wCalc(p.time.millisecondsSinceEpoch);
      int? ping = p.latency;
      if (ping == null) continue;

      // if (i % pWidth < 1) {
      pingLine.moveTo((time), size.height - 16);
      pingLine.lineTo((time), hCalc(ping) + 16);
      count++;
      // }
    }

    // Drawing loop for time
    // Calculate time points by percent of width

    for (double i = 0; i < 0.99; i += (1 / (scale.floor() * 10))) {
      // Cut other optimization
      if ((scr.offset) / size.width < i && (scr.offset + cWidth) / size.width > i) {
        // Draw little points that uses as scale points
        times.moveTo(size.width * i + 10, 0);
        times.lineTo(size.width * i + 10, 5);

        // Calc time by percent of with
        double timeNum = last - timeDiff * i;
        DateTime time = DateTime.fromMillisecondsSinceEpoch(timeNum.toInt());

        // Draw text with time
        TextSpan span = TextSpan(style: TextStyle(color: Color(0xffF5F5F5), fontSize: 10, fontWeight: FontWeight.w200), text: '${time.hour}:${time.minute}');

        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);

        tp.layout();
        tp.paint(canvas, Offset(size.width * i, size.height - 10));
      }
    }

    // print(count);
    // print(cutedList.length);
    // print('executed in ${stopwatch.elapsed}');

    // Set opacity lowest by increasing number of points
    // Its provide stacking on large datasets
    double opacityByCount() {
      double intensityFactor = (1 / (count / size.width)).clamp(0, 1);
      double expo = sqrt(intensityFactor).toDouble();
      return expo;
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
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(GraphPainter oldDelegate) => true;
}
