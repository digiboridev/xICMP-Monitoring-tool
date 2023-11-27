class Host {
  final String adress;
  final bool enabled;

  Host({required this.adress, required this.enabled});

  Host copyWith({String? adress, bool? enabled}) => Host(adress: adress ?? this.adress, enabled: enabled ?? this.enabled);

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
