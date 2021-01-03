import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pingstats/repository/HostModel.dart';
import 'package:pingstats/repository/bloc/HostsDataBloc.dart';
import 'package:provider/provider.dart';

class HostTile extends StatefulWidget {
  HostModel host;

  HostTile(this.host);

  @override
  _HostTileState createState() => _HostTileState();
}

class _HostTileState extends State<HostTile> {
  void doSome() {
    widget.host.toggleIsolate();
  }

  void deleteHost(BuildContext context) {
    HostsDataBloc bloc = context.read<HostsDataBloc>();
    bloc.deleteHost(widget.host.hostname);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: this.doSome,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: StreamBuilder(
                          stream: widget.host.samples,
                          builder: (context, snapshot) {
                            // print(snapshot.data);
                            if (snapshot.hasData) {
                              return AnimIcon('thumb');
                            } else {
                              return AnimIcon('thumb');
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      // padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: StreamBuilder(
                          stream: widget.host.samples,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return FutureBuilder(
                                  future: snapshot.data,
                                  builder: (context, snapshot) {
                                    return Text(
                                        snapshot.data?.length.toString());
                                  });
                            } else {
                              return Text('load');
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.host.hostname),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('AVG:44'),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      width: 50,
                      height: 24,
                      child: StreamBuilder(
                        stream: widget.host.samples,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return FutureBuilder(
                                future: snapshot.data,
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    return CustomPaint(
                                      painter: TileGraph(snapshot.data),
                                    );
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                });
                          } else {
                            return Text('load');
                          }
                        },
                      )),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class AnimIcon extends StatefulWidget {
  AnimIcon(asd);
  // AnimIcon({Key key}) : super(key: key);

  @override
  _AnimIconState createState() => _AnimIconState();
}

class _AnimIconState extends State<AnimIcon> {
  double wd = 20;
  Color c = Colors.white;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AnimIcon oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    wd = 25;
    c = Colors.yellow;
    Timer(Duration(milliseconds: 50), () {
      setState(() {
        wd = 20;
        c = Colors.white;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: wd,
      child: Icon(
        Icons.circle,
        color: c,
      ),
    );
  }
}

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
