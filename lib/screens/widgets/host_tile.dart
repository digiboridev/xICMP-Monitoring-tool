import 'package:flutter/material.dart';
import 'package:xicmpmt/core/sl.dart';
import 'package:xicmpmt/data/models/host.dart';
import 'package:xicmpmt/data/models/ping.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';
import 'package:xicmpmt/screens/widgets/blinking_circle.dart';
import 'package:xicmpmt/screens/widgets/tile_latency.dart';

class HostTile extends StatefulWidget {
  final Host host;
  const HostTile({required this.host, super.key});

  @override
  State<HostTile> createState() => _HostTileState();
}

class _HostTileState extends State<HostTile> {
  final StatsRepository statsRepository = SL.statsRepository;
  final MonitoringService monitoringService = SL.monitoringService;
  List<Ping> samples = [];

  bool expanded = false;
  Duration selectedPeriod = Duration(hours: 3);
  List<DropdownMenuItem<Duration>> periodDropdownList = [
    DropdownMenuItem(
      value: Duration(minutes: 5),
      child: Text('30 mins'),
    ),
    DropdownMenuItem(
      value: Duration(hours: 3),
      child: Text('3 Hours'),
    ),
    DropdownMenuItem(
      value: Duration(hours: 6),
      child: Text('6 Hours'),
    ),
    DropdownMenuItem(
      value: Duration(hours: 12),
      child: Text('12 Hours'),
    ),
    DropdownMenuItem(
      value: Duration(days: 1),
      child: Text('1 day'),
    ),
    DropdownMenuItem(
      value: Duration(days: 3),
      child: Text('3 Days'),
    ),
    DropdownMenuItem(
      value: Duration(days: 7),
      child: Text('Week'),
    ),
  ];

  void toggleRunning() {
    statsRepository.updateHost(widget.host.copyWith(enabled: !widget.host.enabled));
    monitoringService.upsertMonitoring();
    print('toggle running');
  }

  void deleteHost(BuildContext context) {
    statsRepository.deleteHost(widget.host.adress);
    monitoringService.upsertMonitoring();
    print('delete host');
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    samples = await statsRepository.getPingsForHost(widget.host.adress);
    statsRepository.eventBus.where((event) => event is PingAdded && event.ping.host == widget.host.adress).cast<PingAdded>().forEach((event) {
      if (mounted) setState(() => samples.add(event.ping));
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('render hostTile');
    return Column(
      children: [
        InkWell(
          onDoubleTap: toggleRunning,
          onTap: () {
            setState(() => expanded = !expanded);
          },
          child: Opacity(
            opacity: widget.host.enabled ? 1 : 0.5,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder(
                  stream: statsRepository.eventBus.where((event) => event is PingAdded && event.ping.host == widget.host.adress),
                  builder: (context, snapshot) {
                    return BlinkingCircle();
                  },
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(widget.host.adress, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 16),
                SizedBox(width: 80, child: TileLatency(samples: samples)),

                // Container(
                //     // margin: EdgeInsets.symmetric(vertical: 8),
                //     width: 50,
                //     height: 24,
                //     child: StreamBuilder(
                //       stream: widget.host.lastSamples,
                //       builder: (context, snapshot) {
                //         if (snapshot.hasData) {
                //           if (snapshot.data != null) {
                //             return CustomPaint(
                //               painter: TileGraph(snapshot.data),
                //             );
                //           } else {
                //             return Center(
                //               child: CircularProgressIndicator(),
                //             );
                //           }
                //         } else {
                //           return Text('load');
                //         }
                //       },
                //     )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(!expanded ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          height: expanded ? 270 : 0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: ClipRRect(
            child: OverflowBox(
              maxHeight: 270,
              child: expanded
                  ? Column(
                      children: [
                        // Container(
                        //   padding: EdgeInsets.symmetric(horizontal: 16),
                        //   child: StreamBuilder(
                        //       stream: widget.host.samplesPeriod,
                        //       builder: (context, snapshot) {
                        //         if (snapshot.hasData) {
                        //           return Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Row(
                        //               mainAxisAlignment: MainAxisAlignment.start,
                        //               children: [
                        //                 Text('Started: ', style: TextStyle(color: Color(0xffF5F5F5), fontSize: 12, fontWeight: FontWeight.w400)),
                        //                 Text(
                        //                   DateTime.fromMillisecondsSinceEpoch(snapshot.data['first'] ?? 0).toString(),
                        //                   style: TextStyle(color: Color(0xffF5F5F5), fontSize: 12, fontWeight: FontWeight.w400),
                        //                 ),
                        //               ],
                        //             ),
                        //           );
                        //         } else {
                        //           return Container();
                        //         }
                        //       }),
                        // ),
                        // Container(
                        //   padding: EdgeInsets.symmetric(horizontal: 16),
                        //   child: StreamBuilder(
                        //     stream: widget.host.samplesByPeriod,
                        //     initialData: [],
                        //     builder: (context, snapshot) {
                        //       if (snapshot.data.length > 2) {
                        //         return Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), child: TileSummary(snapshot.data));
                        //       } else {
                        //         return Container();
                        //       }
                        //     },
                        //   ),
                        // ),
                        // Container(
                        //     // padding: EdgeInsets.symmetric(horizontal: 16),
                        //     height: 120,
                        //     child: StreamBuilder(
                        //       stream: widget.host.samplesByPeriod,
                        //       initialData: [],
                        //       builder: (context, snapshot) {
                        //         if (snapshot.data.length > 2) {
                        //           return InteractiveGraph(snapshot.data);
                        //         } else {
                        //           return Center(
                        //               child: CircularProgressIndicator(
                        //             backgroundColor: Colors.white,
                        //           ));
                        //         }
                        //       },
                        //     )),
                        // Container(
                        //   padding: EdgeInsets.symmetric(horizontal: 32),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           Text('Show: ', style: TextStyle(color: Color(0xffF5F5F5), fontSize: 12, fontWeight: FontWeight.w400)),
                        //           DropdownButton(
                        //               value: selectedPeriod,
                        //               onChanged: (Duration newValue) {
                        //                 setState(() {
                        //                   selectedPeriod = newValue;
                        //                   widget.host.setPeriod = newValue;
                        //                 });
                        //               },
                        //               icon: null,
                        //               style: TextStyle(color: Color(0xffF5F5F5), fontSize: 12, fontWeight: FontWeight.w400),
                        //               underline: Container(),
                        //               items: periodDropdownList),
                        //         ],
                        //       ),
                        //       Expanded(
                        //           child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.end,
                        //         children: [
                        //           StreamBuilder(
                        //               stream: widget.host.isOn,
                        //               initialData: false,
                        //               builder: (context, snapshot) {
                        //                 return IconButton(
                        //                     icon: Icon(
                        //                       snapshot.data ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        //                       size: 20,
                        //                       color: Color(0xffF5F5F5),
                        //                     ),
                        //                     onPressed: () => toggleRunning());
                        //               }),
                        //           IconButton(
                        //               icon: Icon(
                        //                 Icons.delete_outline,
                        //                 size: 20,
                        //                 color: Color(0xffF5F5F5),
                        //               ),
                        //               onPressed: () => deleteHost(context))
                        //         ],
                        //       ))
                        //     ],
                        //   ),
                        // ),
                      ],
                    )
                  : null,
            ),
          ),
        )
      ],
    );
  }
}
