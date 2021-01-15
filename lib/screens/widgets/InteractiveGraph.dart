import 'dart:math';

import 'package:flutter/material.dart';

class InteractiveGraph extends StatefulWidget {
  // Receives list of pings and time
  List data = [];
  InteractiveGraph(this.data);

  @override
  _InteractiveGraphState createState() => _InteractiveGraphState();
}

class _InteractiveGraphState extends State<InteractiveGraph> {
  //Init scale value
  //Uses for make graph zoomable
  double scale = 1.0;

  //Uses to prevent overzoom
  double prevscale = 1.0;

  ScrollController scr = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Prevent from glitches
    if (widget.data.length < 2) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.all(16),
        // Some times canvas may draws over container
        // Hard clip it
        child: ClipRect(
          // Scroll children and pass offset to it by using Scrollcontroller
          child: SingleChildScrollView(
            controller: scr,
            scrollDirection: Axis.horizontal,
            // Detects scale gesture
            child: GestureDetector(
              // Adjust new scale loocking on prevscale
              onScaleUpdate: (details) {
                setState(() {
                  double asd = scr.offset * sqrt(details.scale);
                  scale = prevscale * details.scale;
                  scr.animateTo(asd,
                      duration: Duration(milliseconds: 1),
                      curve: Curves.linear);
                });
              },
              // After touch down sets new scale as prevscale
              onScaleEnd: (details) {
                setState(() {
                  prevscale = scale;
                });
              },
              child: Container(
                // Grow conteiner width depend on scale value
                width: (MediaQuery.of(context).size.width - 32) * scale,
                child: CustomPaint(
                  painter: GraphPainter(widget.data, scale, scr,
                      (MediaQuery.of(context).size.width - 32)),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class GraphPainter extends CustomPainter {
  List xList = [];

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
    int first = xList.first['time'];
    int last = xList.last['time'];
    int timeDiff = last - first;

    // Calc percent of canvas height by point ping
    double hCalc(p) {
      double h = size.height - 24;
      return (h / 1000 * (1000 - p));
    }

    // Calc percent of canvas width by point time
    double wCalc(time) {
      double timeDiffP = ((last - time) / timeDiff);
      return size.width * timeDiffP;
    }

    // Init pathes
    Path pingLine = Path();
    Path times = Path();

    // Count of drawing point
    // For perfomance debug
    int count = 0;

    // Percent of points for optimizations
    // Last value regulate how many points will display on canvas
    double pWidth = xList.length / 3600;

    Stopwatch stopwatch = new Stopwatch()..start();

    // Drawing loop for ping points

    for (var i = 0; i < xList.length; i++) {
      double time = wCalc(xList[i]['time']);
      int ping = xList[i]['ping'];

      // Optimized hybrid render

      // if ((time > scr.offset && time < scr.offset + cWidth) &&
      //     (i % pWidth < 1)) {
      //   pingLine.moveTo((time), size.height - 16);
      //   pingLine.lineTo((time), hCalc(ping) + 8);
      //   count++;
      // }

      // Render only points inside vievport and cut others

      if ((time > scr.offset && time < scr.offset + cWidth)) {
        pingLine.moveTo((time), size.height - 16);
        pingLine.lineTo((time), hCalc(ping) + 8);
        count++;
      }

      // Render a percent of points

      // if (i % p < 1 || xList[i]['ping'] > 500) {
      //   pingLine.moveTo(wCalc(xList[i]['time']), size.height - 16);
      //   pingLine.lineTo(wCalc(xList[i]['time']), hCalc(xList[i]['ping']) + 8);
      //   count++;
      // }

      // Full render
      // pingLine.moveTo(wCalc(xList[i]['time']), size.height - 16);
      // pingLine.lineTo(wCalc(xList[i]['time']), hCalc(xList[i]['ping']) + 8);
    }

    print(count);

    // Drawing loop for time
    // Calculate time points by percent of width

    for (double i = 0; i < 1; i += (1 / (scale.floor() * 10))) {
      // Cut other optimization
      if ((scr.offset) / size.width < i &&
          (scr.offset + cWidth) / size.width > i) {
        // Draw little points that uses as scale points
        times.moveTo(size.width * i + 10, 0);
        times.lineTo(size.width * i + 10, 5);

        // Calc time by percent of with
        double timeNum = last - timeDiff * i;
        DateTime time = DateTime.fromMicrosecondsSinceEpoch(timeNum.toInt());

        // Draw text with time
        TextSpan span = new TextSpan(
            style: new TextStyle(
                color: Color(0xffF5F5F5),
                fontSize: 10,
                fontWeight: FontWeight.w200),
            text: '${time.hour}:${time.minute}');

        TextPainter tp = new TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);

        tp.layout();
        tp.paint(canvas, new Offset(size.width * i, size.height - 10));
      }
    }
    print('executed in ${stopwatch.elapsed}');

    canvas.drawPath(
        pingLine,
        Paint()
          ..color = Color(0xffFAF338)
          // ..strokeWidth = 1
          ..style = PaintingStyle.stroke);

    canvas.drawPath(
        times,
        Paint()
          ..color = Color(0xffF5F5F5)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke);

    // TODO: implement paint
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(GraphPainter oldDelegate) => true;
}
