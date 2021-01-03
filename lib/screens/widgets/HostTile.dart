import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pingstats/repository/HostModel.dart';
import 'package:pingstats/repository/bloc/HostsDataBloc.dart';
import 'package:pingstats/screens/widgets/BlinkingCircle.dart';
import 'package:pingstats/screens/widgets/TileGraph.dart';
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
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                                  return Text(snapshot.data?.length.toString());
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
        ),
        InkWell(
            onDoubleTap: doSome,
            child: StreamBuilder(
                stream: widget.host.isOn,
                initialData: false,
                builder: (context, snapshot) {
                  return Container(
                    height: 48,
                    color:
                        snapshot.data ? null : Color(0xff1C1C22).withAlpha(200),
                  );
                }))
      ],
    );
  }
}
