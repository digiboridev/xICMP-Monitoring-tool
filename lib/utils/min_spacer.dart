import 'package:flutter/material.dart';

class MinSpacer extends StatelessWidget {
  const MinSpacer({
    this.flex = 1,
    this.minHeight,
    this.minWidth,
    super.key,
  });

  final int flex;
  final double? minHeight;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: SizedBox(
        height: minHeight,
        width: minWidth,
      ),
    );
  }
}
