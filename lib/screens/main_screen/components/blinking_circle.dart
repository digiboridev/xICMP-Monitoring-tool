import 'dart:async';
import 'package:flutter/material.dart';

class BlinkingCircle extends StatefulWidget {
  const BlinkingCircle({super.key});

  @override
  State<BlinkingCircle> createState() => _BlinkingCircleState();
}

class _BlinkingCircleState extends State<BlinkingCircle> {
  double wd = 20;
  Color c = const Color(0xffDB5762);

  @override
  void didUpdateWidget(covariant BlinkingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    wd = 25;
    c = Colors.yellow;
    Timer(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        wd = 20;
        c = const Color(0xffDB5762);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: wd,
      child: Icon(Icons.circle, color: c),
    );
  }
}
