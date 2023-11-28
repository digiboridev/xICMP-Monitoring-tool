// ignore_for_file: public_member_api_docs, sort_constructors_first
class HostStats {
  final int avg;
  final int min;
  final int max;
  final int count;
  final int lostCount;
  final int lossPercent;

  HostStats(this.avg, this.min, this.max, this.count, this.lostCount, this.lossPercent);

  @override
  bool operator ==(covariant HostStats other) {
    if (identical(this, other)) return true;

    return other.avg == avg && other.min == min && other.max == max && other.count == count && other.lostCount == lostCount && other.lossPercent == lossPercent;
  }

  @override
  int get hashCode {
    return avg.hashCode ^ min.hashCode ^ max.hashCode ^ count.hashCode ^ lostCount.hashCode ^ lossPercent.hashCode;
  }

  @override
  String toString() {
    return 'HostStats(avg: $avg, min: $min, max: $max, count: $count, lostCount: $lostCount, lossPercent: $lossPercent)';
  }
}
