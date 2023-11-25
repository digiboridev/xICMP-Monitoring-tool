// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:provider/provider.dart';
// import 'package:xICMP_Monitoring_tool/repository/HostModel.dart';
// import 'package:xICMP_Monitoring_tool/repository/bloc/HostsDataBloc.dart';
// import 'package:xICMP_Monitoring_tool/screens/widgets/BlinkingCircle.dart';
// import 'package:xICMP_Monitoring_tool/screens/widgets/InteractiveGraph.dart';
// import 'package:xICMP_Monitoring_tool/screens/widgets/TileGraph.dart';
// import 'package:xICMP_Monitoring_tool/screens/widgets/TileLatency.dart';
// import 'package:xICMP_Monitoring_tool/screens/widgets/TileSummary.dart';

// class HostTile extends StatefulWidget {
//   final HostModel host;

//   HostTile(this.host);

//   @override
//   _HostTileState createState() => _HostTileState();
// }

// class _HostTileState extends State<HostTile> {
//   bool expanded = false;
//   Duration selectedPeriod = Duration(hours: 3);
//   List<DropdownMenuItem<Duration>> periodDropdownList = [
//     DropdownMenuItem(
//       child: Text('30 mins'),
//       value: Duration(minutes: 5),
//     ),
//     DropdownMenuItem(
//       child: Text('3 Hours'),
//       value: Duration(hours: 3),
//     ),
//     DropdownMenuItem(
//       child: Text('6 Hours'),
//       value: Duration(hours: 6),
//     ),
//     DropdownMenuItem(
//       child: Text('12 Hours'),
//       value: Duration(hours: 12),
//     ),
//     DropdownMenuItem(
//       child: Text('1 day'),
//       value: Duration(days: 1),
//     ),
//     DropdownMenuItem(
//       child: Text('3 Days'),
//       value: Duration(days: 3),
//     ),
//     DropdownMenuItem(
//       child: Text('Week'),
//       value: Duration(days: 7),
//     )
//   ];

//   void toggleRunning() {
//     widget.host.toggleIsolate();
//   }

//   void deleteHost(BuildContext context) {
//     HostsDataBloc bloc = context.read<HostsDataBloc>();
//     bloc.deleteHost(widget.host.hostname);
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // widget.host.samplesPeriod.listen((event) {
//     //   print(event);
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('render hostTile');
//     return Column(
//       children: [
//         InkWell(
//           onDoubleTap: toggleRunning,
//           onTap: () {
//             setState(() {
//               expanded = !expanded;
//             });
//           },
//           child: Stack(
//             children: [
//               Container(
//                 // color: expanded ? Color(0xff121216) : Color(0xff1C1C22),
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 height: 48,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         child: StreamBuilder(
//                           stream: widget.host.updateIndicator,
//                           builder: (context, snapshot) {
//                             return BlinkingCircle('thumb');
//                           },
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                         child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Text(widget.host.hostname),
//                       ),
//                     )),
//                     Container(
//                         // height: 24,
//                         width: 50,
//                         padding: EdgeInsets.only(right: 8),
//                         child: StreamBuilder(
//                           stream: widget.host.lastSamples,
//                           builder: (context, snapshot) {
//                             if (snapshot.hasData) {
//                               if (snapshot.data != null) {
//                                 return TileLatency(snapshot.data);
//                               } else {
//                                 return Center(
//                                   child: CircularProgressIndicator(),
//                                 );
//                               }
//                             } else {
//                               return Text('load');
//                             }
//                           },
//                         )),
//                     Container(
//                         // margin: EdgeInsets.symmetric(vertical: 8),
//                         width: 50,
//                         height: 24,
//                         child: StreamBuilder(
//                           stream: widget.host.lastSamples,
//                           builder: (context, snapshot) {
//                             if (snapshot.hasData) {
//                               if (snapshot.data != null) {
//                                 return CustomPaint(
//                                   painter: TileGraph(snapshot.data),
//                                 );
//                               } else {
//                                 return Center(
//                                   child: CircularProgressIndicator(),
//                                 );
//                               }
//                             } else {
//                               return Text('load');
//                             }
//                           },
//                         )),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Icon(!expanded
//                           ? Icons.arrow_drop_down
//                           : Icons.arrow_drop_up),
//                     )
//                   ],
//                 ),
//               ),
//               StreamBuilder(
//                   stream: widget.host.isOn,
//                   initialData: false,
//                   builder: (context, snapshot) {
//                     return IgnorePointer(
//                       child: Container(
//                         height: 48,
//                         color: snapshot.data
//                             ? null
//                             : Color(0xff121216).withAlpha(200),
//                       ),
//                     );
//                   }),
//             ],
//           ),
//         ),
//         AnimatedContainer(
//           height: expanded ? 270 : 0,
//           duration: Duration(milliseconds: 200),
//           curve: Curves.easeInOut,
//           child: ClipRRect(
//             child: OverflowBox(
//               maxHeight: 270,
//               child: expanded
//                   ? Column(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           child: StreamBuilder(
//                               stream: widget.host.samplesPeriod,
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   return Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         Text('Started: ',
//                                             style: TextStyle(
//                                                 color: Color(0xffF5F5F5),
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w400)),
//                                         Text(
//                                             DateTime.fromMillisecondsSinceEpoch(
//                                                     snapshot.data['first'] ?? 0)
//                                                 .toString(),
//                                             style: TextStyle(
//                                                 color: Color(0xffF5F5F5),
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w400))
//                                       ],
//                                     ),
//                                   );
//                                 } else {
//                                   return Container();
//                                 }
//                               }),
//                         ),
//                         Container(
//                             padding: EdgeInsets.symmetric(horizontal: 16),
//                             child: StreamBuilder(
//                                 stream: widget.host.samplesByPeriod,
//                                 initialData: [],
//                                 builder: (context, snapshot) {
//                                   if (snapshot.data.length > 2) {
//                                     return Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 8, horizontal: 8),
//                                         child: TileSummary(snapshot.data));
//                                   } else {
//                                     return Container();
//                                   }
//                                 })),
//                         Container(
//                             // padding: EdgeInsets.symmetric(horizontal: 16),
//                             height: 120,
//                             child: StreamBuilder(
//                               stream: widget.host.samplesByPeriod,
//                               initialData: [],
//                               builder: (context, snapshot) {
//                                 if (snapshot.data.length > 2) {
//                                   return InteractiveGraph(snapshot.data);
//                                 } else {
//                                   return Center(
//                                       child: CircularProgressIndicator(
//                                     backgroundColor: Colors.white,
//                                   ));
//                                 }
//                               },
//                             )),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 32),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text('Show: ',
//                                       style: TextStyle(
//                                           color: Color(0xffF5F5F5),
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w400)),
//                                   DropdownButton(
//                                       value: selectedPeriod,
//                                       onChanged: (Duration newValue) {
//                                         setState(() {
//                                           selectedPeriod = newValue;
//                                           widget.host.setPeriod = newValue;
//                                         });
//                                       },
//                                       icon: null,
//                                       style: TextStyle(
//                                           color: Color(0xffF5F5F5),
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w400),
//                                       underline: Container(),
//                                       items: periodDropdownList),
//                                 ],
//                               ),
//                               Expanded(
//                                   child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   StreamBuilder(
//                                       stream: widget.host.isOn,
//                                       initialData: false,
//                                       builder: (context, snapshot) {
//                                         return IconButton(
//                                             icon: Icon(
//                                               snapshot.data
//                                                   ? Icons.pause_circle_outline
//                                                   : Icons.play_circle_outline,
//                                               size: 20,
//                                               color: Color(0xffF5F5F5),
//                                             ),
//                                             onPressed: () => toggleRunning());
//                                       }),
//                                   IconButton(
//                                       icon: Icon(
//                                         Icons.delete_outline,
//                                         size: 20,
//                                         color: Color(0xffF5F5F5),
//                                       ),
//                                       onPressed: () => deleteHost(context))
//                                 ],
//                               ))
//                             ],
//                           ),
//                         ),
//                       ],
//                     )
//                   : null,
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }
