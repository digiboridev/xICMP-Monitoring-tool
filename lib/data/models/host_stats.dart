// ignore_for_file: public_member_api_docs, sort_constructors_first
class HostStats {
  final double avg;
  final double min;
  final double max;
  final int count;
  final int numCount;
  final int lossPercent;

  HostStats(this.avg, this.min, this.max, this.count, this.numCount, this.lossPercent);

  @override
  bool operator ==(covariant HostStats other) {
    if (identical(this, other)) return true;

    return other.avg == avg && other.min == min && other.max == max && other.count == count && other.numCount == numCount && other.lossPercent == lossPercent;
  }

  @override
  int get hashCode {
    return avg.hashCode ^ min.hashCode ^ max.hashCode ^ count.hashCode ^ numCount.hashCode ^ lossPercent.hashCode;
  }

  @override
  String toString() {
    return 'HostStats(avg: $avg, min: $min, max: $max, count: $count, numCount: $numCount, lossPercent: $lossPercent)';
  }
}
