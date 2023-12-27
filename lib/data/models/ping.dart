import 'package:equatable/equatable.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Ping with EquatableMixin {
  final String host;
  final DateTime time;
  final int latency;
  final bool lost;
  Ping({required this.host, required this.time, required this.latency, required this.lost});

  @override
  List<Object> get props => [host, time, latency, lost];

  @override
  String toString() {
    return 'Ping(host: $host, time: $time, latency: $latency, lost: $lost)';
  }
}
