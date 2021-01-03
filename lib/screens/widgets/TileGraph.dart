import 'package:flutter/material.dart';

class TileGraph extends CustomPainter {
  List xList = [];

  TileGraph(List samples) {
    var rev = samples.reversed;

    int count = 0;

    for (var item in rev) {
      if (count >= 50) {
        break;
      }
      xList.add(item);
      count++;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // print(size);
    double hCalc(p) {
      double h = size.height;
      return (h / 1000 * (1000 - p));
    }

    var rect = Offset.zero & Size(size.width, size.height);

    canvas.drawRect(rect, Paint()..color = Color(0xffFAF338));
    Path ctx = Path();

    for (var i = 1; i < xList.length; i++) {
      ctx.moveTo(i - 1.0, hCalc(xList[i - 1]['ping']));
      ctx.lineTo(i.toDouble(), hCalc(xList[i]['ping']));
    }

    canvas.drawPath(
        ctx,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke);
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(TileGraph oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(TileGraph oldDelegate) => false;
}
