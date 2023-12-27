// ignore_for_file: unused_element
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xicmpmt/data/models/ping.dart';

/// Paints a preview histogram of the recent latency samples
///
/// Optimized for performance by
/// using constant step rather than mapping to time
/// using known dataset length to iterate over samples only once per frame without length lookup
/// using a pool of precalculated line heights to avoid recalculating them on every frame
class PreviewHistorgamPainter extends CustomPainter {
  final Iterable<Ping> samples;
  final int maxValue;
  final int length;
  const PreviewHistorgamPainter(this.samples, {this.maxValue = 1000, this.length = 100});

  static final _linePaint = Paint()..color = Colors.black;
  static final _lossPaint = Paint()..color = Colors.red;
  static final Map<int, double> _lineHeightPool = {};

  @override
  void paint(Canvas canvas, Size size) {
    double lineHeight(int v) {
      double scale = (v / maxValue).clamp(0, 1);
      final invert = 1 - scale;
      return (size.height * invert);
    }

    double lineHeightExpo(int v) {
      double scale = (v / maxValue).clamp(0, 1);
      scale = sqrt(scale);
      final invert = 1 - scale;
      return (size.height * invert);
    }

    double lineHeightWrapp(int v) {
      return _lineHeightPool.putIfAbsent(v, () => lineHeightExpo(v));
    }

    var rect = Offset.zero & Size(size.width, size.height);
    canvas.drawRect(rect, Paint()..color = Colors.yellowAccent);

    final double step = size.width / (length - 1);

    for (var i = 0; i < length - 1; i++) {
      final el1 = samples.elementAtOrNull(i);
      final el2 = samples.elementAtOrNull(i + 1);
      if (el1 == null || el2 == null) continue;

      final x1 = i * step;
      final v1 = el1.latency;
      final x2 = (i + 1) * step;
      final v2 = el2.latency;

      if (el1.lost || el2.lost) {
        canvas.drawRect(Offset(x1, 0) & Size(step, size.height), _lossPaint);
      } else {
        final y1 = lineHeightWrapp(v1);
        final y2 = lineHeightWrapp(v2);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), _linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(PreviewHistorgamPainter oldDelegate) => true;
}
