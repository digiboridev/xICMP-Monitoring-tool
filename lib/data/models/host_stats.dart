import 'package:equatable/equatable.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class HostStats with EquatableMixin {
  final int avg;
  final int min;
  final int max;
  final int count;
  final int lostCount;
  final int lossPercent;

  HostStats(this.avg, this.min, this.max, this.count, this.lostCount, this.lossPercent);

  @override
  List<Object> get props {
    return [avg, min, max, count, lostCount, lossPercent];
  }

  @override
  String toString() {
    return 'HostStats(avg: $avg, min: $min, max: $max, count: $count, lostCount: $lostCount, lossPercent: $lossPercent)';
  }
}
