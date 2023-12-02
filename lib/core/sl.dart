import 'package:xicmpmt/data/drift/db.dart';
import 'package:xicmpmt/data/repositories/settings.dart';
import 'package:xicmpmt/data/repositories/stats.dart';
import 'package:xicmpmt/data/service/monitoring.dart';

abstract class SL {
  static final _drift = DB();

  static final SettingsRepository settingsRepository = SettingsRepositoryPrefsImpl();
  static final StatsRepository statsRepository = StatsRepositoryDriftImpl(_drift.statsDao);

  static final MonitoringService monitoringService = MonitoringService(statsRepository, settingsRepository);
}
