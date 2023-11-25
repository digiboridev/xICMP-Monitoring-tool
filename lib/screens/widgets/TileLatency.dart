// import 'package:flutter/material.dart';

// // Return avg latency and lost percent of last 100 points

// class TileLatency extends StatelessWidget {
//   TextStyle st = TextStyle(fontSize: 10, fontWeight: FontWeight.w400);
//   int avg = 0;
//   int loss = 0;

//   TileLatency(List samples) {
//     var rev = samples.reversed;

//     int count = 0;
//     int sum = 0;

//     for (var item in rev) {
//       // print(item);
//       if (count >= 100) {
//         break;
//       }

//       count++;

//       num value = item['ping'];

//       if (value > 0 && value < 1000) {
//         sum += value;
//       }

//       if (value == 0 || value == 1000) {
//         loss++;
//       }
//     }
//     if (count > 0) {
//       avg = (sum / count)?.toInt() ?? 0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '${avg} ms',
//           style: st,
//         ),
//         Text(
//           '${loss}% loss',
//           style: st,
//         )
//       ],
//     );
//   }
// }
