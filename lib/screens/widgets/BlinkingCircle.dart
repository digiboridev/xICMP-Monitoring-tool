// import 'dart:async';

// import 'package:flutter/material.dart';

// class BlinkingCircle extends StatefulWidget {
//   BlinkingCircle(asd);

//   @override
//   _BlinkingCircleState createState() => _BlinkingCircleState();
// }

// class _BlinkingCircleState extends State<BlinkingCircle> {
//   double wd = 20;
//   Color c = Color(0xffDB5762);

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void didUpdateWidget(covariant BlinkingCircle oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     wd = 25;
//     c = Colors.yellow;
//     Timer(Duration(milliseconds: 50), () {
//       setState(() {
//         wd = 20;
//         c = Color(0xffDB5762);
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 200),
//       width: wd,
//       child: Icon(
//         Icons.circle,
//         color: c,
//       ),
//     );
//   }
// }
