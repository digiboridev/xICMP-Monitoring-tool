// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class Host with EquatableMixin {
  final String adress;
  final bool enabled;
  Host({required this.adress, required this.enabled});

  Host copyWith({String? adress, bool? enabled}) => Host(adress: adress ?? this.adress, enabled: enabled ?? this.enabled);

  @override
  List<Object> get props => [adress, enabled];

  @override
  String toString() => 'Host(adress: $adress, enabled: $enabled)';
}
