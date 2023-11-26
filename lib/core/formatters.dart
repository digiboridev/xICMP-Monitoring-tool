import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

abstract class AppFormatters {
  static final ipFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'));
  static final phoneFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9\+]'));
  static final numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  static final nameFormatter = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ ]'));
}

extension FormatDate on DateTime {
  DateFormat get formatter => DateFormat('yyyy-MM-dd HH:mm:ss');

  String get ymdhms => formatter.format(this);

  String get numhms => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  String get numymd => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

extension FormatDuration on Duration {
  String get hms => '$inHours:${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
}
