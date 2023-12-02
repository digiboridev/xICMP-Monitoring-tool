import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xicmpmt/data/models/settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> get getSettings;
  Future<void> setSettings(AppSettings settings);
  Stream<AppSettings> get updatesStream;
}

class SettingsRepositoryPrefsImpl implements SettingsRepository {
  SharedPreferences? _prefsInstance;
  late final _streamController = StreamController<AppSettings>.broadcast();

  Future<SharedPreferences> get _getPrefs async => _prefsInstance ??= await SharedPreferences.getInstance();

  @override
  Future<AppSettings> get getSettings async {
    final prefs = await _getPrefs;
    final settings = prefs.getString('app_settings');
    if (settings != null) {
      return AppSettings.fromJson(settings);
    } else {
      return AppSettings.base();
    }
  }

  @override
  Future<void> setSettings(AppSettings settings) async {
    final prefs = await _getPrefs;
    await prefs.setString('app_settings', settings.toJson());
    _streamController.add(settings);
  }

  @override
  Stream<AppSettings> get updatesStream => _streamController.stream;
}
