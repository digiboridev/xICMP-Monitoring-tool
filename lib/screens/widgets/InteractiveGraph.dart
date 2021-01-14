import 'package:flutter/material.dart';

class InteractiveGraph extends StatefulWidget {
  List data = [];
  InteractiveGraph(this.data);

  @override
  _InteractiveGraphState createState() => _InteractiveGraphState();
}

class _InteractiveGraphState extends State<InteractiveGraph> {
  double width = 400;
  double prevwidth = 400;
  double scale = 1.0;
  double prevscale = 1.0;

  @override
  void didUpdateWidget(covariant InteractiveGraph oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                scale = prevscale * details.scale;
              });
            },
            onScaleEnd: (details) {
              setState(() {
                prevscale = scale;
              });
            },
            child: Container(
              // color: Colors.amber,
              width: (MediaQuery.of(context).size.width - 32) * scale,

              child: CustomPaint(
                painter: GraphPainter(widget.data, scale),
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
  double scale;

  GraphPainter(this.xList, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    int first = xList.first['time'];
    int last = xList.last['time'];
    int timeDiff = last - first;

    double hCalc(p) {
      double h = size.height - 16;
      return (h / 1000 * (1000 - p));
    }

    double wCalc(time) {
      double timeDiffP = ((last - time) / timeDiff);
      return size.width * timeDiffP;
    }

    // var rect = Offset(0, 0) & Size(size.width, size.height - 16);

    // canvas.drawRect(rect, Paint()..color = Color(0xffFAF338));
    Path pingLine = Path();

    for (var i = 1; i < xList.length; i++) {
      // ctx.moveTo(wCalc(xList[i - 1]['time']), hCalc(xList[i - 1]['ping']));
      pingLine.moveTo(wCalc(xList[i]['time']), size.height - 16);
      pingLine.lineTo(wCalc(xList[i]['time']), hCalc(xList[i]['ping']));
    }

    canvas.drawPath(
        pingLine,
        Paint()
          ..color = Color(0xffFAF338)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke);

    Path times = Path();

    for (double i = 0; i < 1; i += (1 / (scale.floor() * 10))) {
      times.moveTo(size.width * i + 10, 0);
      times.lineTo(size.width * i + 10, 5);

      double timeNum = last - timeDiff * i;
      DateTime time = DateTime.fromMicrosecondsSinceEpoch(timeNum.toInt());

      // print('${time.hour}:${time.minute}');

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
