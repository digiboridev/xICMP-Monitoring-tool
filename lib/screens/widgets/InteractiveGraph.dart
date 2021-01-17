import 'package:flutter/material.dart';

class InteractiveGraph extends StatefulWidget {
  // Receives list of pings and time
  final List data;
  InteractiveGraph(this.data);

  @override
  _InteractiveGraphState createState() => _InteractiveGraphState();
}

class _InteractiveGraphState extends State<InteractiveGraph> {
  //Init scale value
  //Uses for make graph zoomable
  double scale = 1.0;

  //Uses to zoom and scroll calculations
  double prevscale = 1.0;
  double prevOffset = 0;

  ScrollController scr = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
      double h = size.height - 32;
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
    Path scaleMs = Path();

    for (var i = 0; i < 5; i++) {
      TextSpan span = new TextSpan(
          style: new TextStyle(
              color: Color(0xffF5F5F5),
              fontSize: 6,
              fontWeight: FontWeight.w200),
          text: '${i * 200}');

      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);

      tp.layout();
      tp.paint(canvas, new Offset(0, hCalc(i * 200)));
      tp.paint(canvas, new Offset(size.width - 8, hCalc(i * 200)));
    }

    // Count of drawing point
    // For perfomance debug
    int count = 0;

    // Stopwatch stopwatch = new Stopwatch()..start();

    // Drawing loop for ping points

    // Cut outer of screen points fir optimizations
    // Uses scroll offset from parent to calc it
    List cutedList = [];

    for (var i = 0; i < xList.length; i++) {
      double time = wCalc(xList[i]['time']);
      if (time > scr.offset && time < scr.offset + cWidth) {
        cutedList.add(xList[i]);
      }
    }

    // Percent of points for optimizations
    // Last value regulate how many points will display on canvas
    double pWidth = cutedList.length / 9000;

    for (var i = 0; i < cutedList.length; i++) {
      double time = wCalc(cutedList[i]['time']);
      int ping = cutedList[i]['ping'];

      if (i % pWidth < 1) {
        pingLine.moveTo((time), size.height - 16);
        pingLine.lineTo((time), hCalc(ping) + 16);
        count++;
      }
    }

    // Drawing loop for time
    // Calculate time points by percent of width

    for (double i = 0; i < 0.99; i += (1 / (scale.floor() * 10))) {
      // Cut other optimization
      if ((scr.offset) / size.width < i &&
          (scr.offset + cWidth) / size.width > i) {
        // Draw little points that uses as scale points
        times.moveTo(size.width * i + 10, 0);
        times.lineTo(size.width * i + 10, 5);

        // Calc time by percent of with
        double timeNum = last - timeDiff * i;
        DateTime time = DateTime.fromMillisecondsSinceEpoch(timeNum.toInt());

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

    // print(count);
    // print(cutedList.length);
    // print('executed in ${stopwatch.elapsed}');

    // Set opacity lowest by increasing number of points
    // Its provide stacking on large datasets
    int brightByCount() {
      int asd = 255 - (255 * (count / 10000)).toInt();
      return asd;
    }

    canvas.drawPath(
        pingLine,
        Paint()
          ..color = Color(0xffFAF338).withAlpha(brightByCount())
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
