// ignore_for_file: public_member_api_docs, sort_constructors_first
class Ping {
  final String host;
  final DateTime time;
  final int? latency;
  Ping({required this.host, required this.time, this.latency});

  @override
  bool operator ==(covariant Ping other) {
    if (identical(this, other)) return true;

    return other.host == host && other.time == time && other.latency == latency;
  }

  @override
  int get hashCode => host.hashCode ^ time.hashCode ^ latency.hashCode;

  @override
  String toString() => 'Ping(host: $host, time: $time, latency: $latency)';
}
