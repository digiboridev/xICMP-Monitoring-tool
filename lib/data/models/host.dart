class Host {
  final String adress;
  final bool enabled;

  Host({required this.adress, required this.enabled});

  @override
  bool operator ==(covariant Host other) {
    if (identical(this, other)) return true;

    return other.adress == adress && other.enabled == enabled;
  }

  @override
  int get hashCode => adress.hashCode ^ enabled.hashCode;

  @override
  String toString() => 'Host(adress: $adress, enabled: $enabled)';
}
