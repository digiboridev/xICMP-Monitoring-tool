import 'dart:io';

import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:pingstats/repository/bloc/HostsDataBloc.dart';
import 'package:pingstats/screens/widgets/HostTile.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  HostsDataBloc bloc;
  bool wakelock = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc = context.read<HostsDataBloc>();
    // bloc.hosts.listen((event) {
    //   event.then((value) => print(value));
    // });
  }

  void startAll() {
    bloc.startAll();
  }

  void stopAll() {
    bloc.stopAll();
  }

  void addDialog() async {
    String _dialogText = 'asd';
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('External adress input'),
              content: Container(
                  height: 40,
                  child: TextField(
                    onChanged: (v) => _dialogText = v,
                  )),
              actions: [
                FlatButton(
                    onPressed: () {
                      print(_dialogText);
                      Navigator.pop(context, true);
                      bloc.addHost(_dialogText);
                    },
                    child: Text('Save')),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text('Decline'))
              ]);
        });
  }

  void deleteAll() {
    bloc.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    // bloc.addHost('speedtest.net');
    // bloc.deleteHost('speeqweqwd');

    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        print('minimized');
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Monitoring hosts'),
          ),
          endDrawer: Container(
            width: 200,
            child: Drawer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   height: 100,
                    //   child: DrawerHeader(
                    //       child: Center(child: Text('PingStats v 1.0'))),
                    // ),
                    Expanded(
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                                color: Color(0xff1C1C22),
                                onPressed: addDialog,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.add),
                                    ),
                                    Text('Add host')
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                                color: Color(0xff1C1C22),
                                onPressed: startAll,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.play_arrow),
                                    ),
                                    Text('Start all')
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                                color: Color(0xff1C1C22),
                                onPressed: stopAll,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.stop),
                                    ),
                                    Text('Stop all')
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                                color: Color(0xffDB5762),
                                onPressed: deleteAll,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.delete_outlined),
                                    ),
                                    Text('Delete all')
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                                color: Color(0xff1C1C22),
                                onPressed: () =>
                                    MoveToBackground.moveTaskToBack(),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.minimize),
                                    ),
                                    Text('Minimize')
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                                color: Color(0xff1C1C22),
                                onPressed: () => exit(0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.minimize),
                                    ),
                                    Text('Close app')
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('WakeLock'),
                                Switch(
                                    activeColor: Color(0xffDB5762),
                                    value: wakelock,
                                    onChanged: (b) {
                                      setState(() {
                                        wakelock = b;
                                      });
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('PingStats 1.0'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'digiborimusik@gmail.com',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Container(
                //   height: 36,
                //   child: Row(
                //     children: [
                //       IconButton(
                //           icon: Icon(
                //             Icons.play_arrow,
                //             color: Color(0xffEBEBEB),
                //           ),
                //           tooltip: 'Start all',
                //           onPressed: startAll),
                //       IconButton(
                //           icon: Icon(
                //             Icons.stop,
                //             color: Color(0xffEBEBEB),
                //           ),
                //           tooltip: 'Stop all',
                //           onPressed: stopAll),
                //       IconButton(
                //           icon: Icon(
                //             Icons.add,
                //             color: Color(0xffEBEBEB),
                //           ),
                //           tooltip: 'Add host',
                //           onPressed: addDialog),
                //       IconButton(
                //           icon: Icon(
                //             Icons.do_disturb_sharp,
                //             color: Color(0xffEBEBEB),
                //           ),
                //           tooltip: 'Delete all',
                //           onPressed: deleteAll)
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status'),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Host'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('Latency'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        margin: EdgeInsets.only(right: 32),
                        child: Text('Preview'),
                      ),
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
          )),
    );
  }
}
