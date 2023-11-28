// ignore_for_file: public_member_api_docs, sort_constructors_first
class Ping {
  final String host;
  final DateTime time;
  final int latency;
  final bool lost;
  Ping({required this.host, required this.time, required this.latency, required this.lost});

  @override
  bool operator ==(covariant Ping other) {
    if (identical(this, other)) return true;

    return other.host == host && other.time == time && other.latency == latency && other.lost == lost;
  }

  @override
  int get hashCode {
    return host.hashCode ^ time.hashCode ^ latency.hashCode ^ lost.hashCode;
  }

  @override
  String toString() {
    return 'Ping(host: $host, time: $time, latency: $latency, lost: $lost)';
  }
}
