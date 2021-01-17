import 'package:flutter/material.dart';

class TileLatency extends StatefulWidget {
  // List xList = [];
  int min = 1000;
  int max = 0;
  int avg = 0;
  int loss = 0;

  TileLatency(List samples) {
    var rev = samples.reversed;

    int count = 0;
    int sum = 0;

    for (var item in rev) {
      // print(item);
      if (count >= 100) {
        break;
      }

      count++;

      num value = item['ping'];

      if (value < min && value > 0) {
        min = value;
      }

      if (value > max && value < 1000) {
        max = value;
      }

      if (value > 0 && value < 1000) {
        sum += value;
      }

      if (value == 0 || value == 1000) {
        loss++;
      }
    }
    if (count > 0) {
      avg = (sum / count)?.toInt() ?? 0;
    }
  }

  @override
  _TileLatencyState createState() => _TileLatencyState();
}

class _TileLatencyState extends State<TileLatency> {
  TextStyle st = TextStyle(fontSize: 10, fontWeight: FontWeight.w400);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.avg} avg',
          style: st,
        ),
        Text(
          '${widget.loss}% loss',
          style: st,
        )
      ],
    );
  }
}
