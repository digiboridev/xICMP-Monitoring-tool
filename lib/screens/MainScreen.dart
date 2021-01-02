import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pingstats/repository/bloc/HostsDataBloc.dart';
import 'package:provider/provider.dart';
import 'package:pingstats/repository/HostModel.dart';
import 'package:pingstats/repository/HostsRepo.dart';
import 'package:pingstats/repository/SqfDB.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  HostsDataBloc bloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc = context.read<HostsDataBloc>();
    bloc.hosts.listen((event) {
      event.then((value) => print(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    // bloc.addHost('beeg.com');
    // bloc.deleteHost('speeqweqwd');

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text('Status'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Count'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Host'),
                  )
                ]),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Latency'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Graph'),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
              child: StreamBuilder(
            stream: bloc.hosts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FutureBuilder(
                  future: snapshot.data,
                  builder: (context, s2) {
                    if (s2.connectionState == ConnectionState.done) {
                      return ListView.builder(
                          itemCount: s2.data.length,
                          itemBuilder: (_, i) => HostTile(s2.data[i]));
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              } else {
                return Center(
                  child: Text('INITIALIZE'),
                );
              }
            },
          ))
        ],
      ),
    );
  }
}

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
                      child: Icon(Icons.circle),
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
                    color: Colors.yellow,
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
