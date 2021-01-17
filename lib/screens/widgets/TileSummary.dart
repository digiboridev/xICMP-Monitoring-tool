import 'package:flutter/material.dart';

class TileSummary extends StatefulWidget {
  int min = 1000;
  int max = 0;
  int avg = 0;
  int loss = 0;
  int lossP;

  TileSummary(List samples) {
    var rev = samples.reversed;

    int count = 0;
    int sum = 0;

    for (var item in rev) {
      // print(item);
      // if (count >= 100) {
      //   break;
      // }

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

    lossP = (loss / samples.length * 100).toInt();
  }

  @override
  _TileSummaryState createState() => _TileSummaryState();
}

class _TileSummaryState extends State<TileSummary> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
            'AVG: ${widget.avg} / MIN: ${widget.min} / MAX: ${widget.max} / LOSS: ${widget.lossP}%',
            style: TextStyle(
                color: Color(0xffF5F5F5),
                fontSize: 12,
                fontWeight: FontWeight.w400))
      ],
    );
  }
}
