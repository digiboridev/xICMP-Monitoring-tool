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
  double offset = 0;

  //Uses to zoom and scroll calculations
  double prevscale = 1.0;
  double prevOffset = 0;

  late final ScrollController scr = ScrollController();

  Duration selectedPeriod = Duration(minutes: 5);
  late DateTime from = DateTime.now().subtract(selectedPeriod);
  late DateTime to = DateTime.now();

  List<DropdownMenuItem<Duration>> periodDropdownList = [
    DropdownMenuItem(
      value: Duration(minutes: 5),
      child: Text('5 mins'),
    ),
    DropdownMenuItem(
      value: Duration(minutes: 30),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
      scr.addListener(() {
        offset = scr.offset;
        print(offset);
        setState(() {});
      });
    });
  }

  loadData() async {
    final rasterWidth = MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;

    final newData = await SL.statsRepository.getPingsForHostPeriodScale(widget.host, from, to, (2000 * scale).toInt());
    if (!mounted) return;

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
                        // Adjust scale
                        scale = prevscale * details.scale;
                        scale < 1.0 ? scale = 1.0 : scale = scale;

                        // Jump to offset proportionaly to scale
                        double newOffset = prevOffset * details.scale + details.focalPoint.dx * (details.scale - 1);
                        if (scale > 1.0) scr.jumpTo(newOffset);
                        print(scale);
                      });
                    },

                    onScaleEnd: (details) {
                      loadData();
                      print('end');
                    },
                    child: SizedBox(
                      // Grow conteiner width depend on scale value
                      width: width * scale,
                      child: CustomPaint(
                        painter: GraphPainter(data, scale, offset, width, from, to),
                      ),
                    ),
                  ),
                ),
              );
            },
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
                  final now = DateTime.now();
                  selectedPeriod = newValue;
                  from = now.subtract(selectedPeriod);
                  to = now;
                  scale = 1.0;
                  offset = 0;
                  scr.jumpTo(0);
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
  final Iterable<Ping> dataSet;
  final DateTime start;
  final DateTime end;

  // Widget width scale
  double scale;

  // Scroll controller or scrollview
  // Uses for position calculations
  double offset;

  // Container width
  // Uses for vievport calculations
  double cWidth;

  GraphPainter(this.dataSet, this.scale, this.offset, this.cWidth, this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    // Main time values
    // Needs for scaling and positioning point on canvas
    int first = start.millisecondsSinceEpoch;
    int last = end.millisecondsSinceEpoch;
    int timeDiff = last - first;
    int viewPortTimeStampStart = (last - timeDiff * (offset / size.width)).toInt();
    int viewPortTimeStampEnd = (last - timeDiff * ((offset + cWidth) / size.width)).toInt();

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
      final twidth = tp.size.width;

      tp.paint(canvas, Offset(offset, hCalc(i * 200)));
      tp.paint(canvas, Offset((offset + cWidth) - twidth, hCalc(i * 200)));
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

    // Set opacity lowest by increasing number of points
    // Its provide stacking on large datasets
    double opacityByCount() {
      double intensityFactor = (1 / (count / cWidth)).clamp(0, 1);
      // return intensityFactor;
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
