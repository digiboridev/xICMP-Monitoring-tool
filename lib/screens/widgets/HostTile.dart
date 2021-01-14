import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pingstats/repository/HostModel.dart';
import 'package:pingstats/repository/bloc/HostsDataBloc.dart';
import 'package:pingstats/screens/widgets/BlinkingCircle.dart';
import 'package:pingstats/screens/widgets/InteractiveGraph.dart';
import 'package:pingstats/screens/widgets/TileGraph.dart';
import 'package:provider/provider.dart';

class HostTile extends StatefulWidget {
  HostModel host;

  HostTile(this.host);

  @override
  _HostTileState createState() => _HostTileState();
}

class _HostTileState extends State<HostTile> {
  bool expanded = false;

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
        InkWell(
          onDoubleTap: doSome,
          onTap: () {
            setState(() {
              expanded = !expanded;
            });
          },
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                height: 48,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: StreamBuilder(
                          stream: widget.host.samples,
                          builder: (context, snapshot) {
                            return BlinkingCircle('thumb');
                          },
                        ),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(widget.host.hostname),
                      ),
                    )),
                    Container(
                        // height: 24,
                        width: 45,
                        padding: EdgeInsets.only(right: 8),
                        child: StreamBuilder(
                          stream: widget.host.samples,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                return TileLatency(snapshot.data);
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            } else {
                              return Text('load');
                            }
                          },
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        width: 50,
                        height: 24,
                        child: StreamBuilder(
                          stream: widget.host.samples,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data != null) {
                                return CustomPaint(
                                  painter: TileGraph(snapshot.data),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            } else {
                              return Text('load');
                            }
                          },
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(!expanded
                          ? Icons.arrow_drop_down
                          : Icons.arrow_drop_up),
                    )
                  ],
                ),
              ),
              StreamBuilder(
                  stream: widget.host.isOn,
                  initialData: false,
                  builder: (context, snapshot) {
                    return IgnorePointer(
                      child: Container(
                        height: 48,
                        color: snapshot.data
                            ? null
                            : Color(0xff1C1C22).withAlpha(200),
                      ),
                    );
                  }),
            ],
          ),
        ),
        AnimatedContainer(
            // color: Color(0xff25252D),
            duration: Duration(milliseconds: 200),
            height: expanded ? 120 : 0,
            child: expanded
                ? StreamBuilder(
                    stream: widget.host.samples,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != null) {
                          return InteractiveGraph(snapshot.data);
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      } else {
                        return Text('load');
                      }
                    },
                  )
                : null)
      ],
    );
  }
}

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
  TextStyle st = TextStyle(fontSize: 10, fontWeight: FontWeight.w100);

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
