import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/domain/datasources/video_post_local_store.dart';

class SeasonProvider extends ChangeNotifier {
  SeasonProvider({required this.localStore});

  static const _appIconChannel = MethodChannel('com.example.toktik/app_icon');

  final VideoPostLocalStore localStore;
  AppSeason? _seasonOverride;
  DateTime? _forcedDate;

  AppSeason get season =>
      _seasonOverride ?? AppTheme.seasonForDate(_forcedDate ?? DateTime.now());
  AppSeason? get seasonOverride => _seasonOverride;
  DateTime? get forcedDate => _forcedDate;

  Future<void> load() async {
    final preferences = await localStore.getSeasonPreferences();
    final seasonOverride = _seasonFromName(preferences.seasonOverride);
    if (preferences.seasonOverride != null && seasonOverride == null) {
      throw FormatException(
        'Stored season override is invalid: ${preferences.seasonOverride}',
      );
    }
    _seasonOverride = seasonOverride;
    _forcedDate = preferences.forcedDate;
    notifyListeners();
    try {
      await _syncAndroidAppIcon(season);
    } on PlatformException catch (error, stackTrace) {
      debugPrint(
        'Android app icon could not be synchronized: $error\n$stackTrace',
      );
    } on MissingPluginException catch (error, stackTrace) {
      debugPrint(
        'Android app icon channel is unavailable: $error\n$stackTrace',
      );
    }
  }

  Future<void> selectSeason(AppSeason? season) async {
    final updated = SeasonPreferences(
      seasonOverride: season?.name,
      forcedDate: _forcedDate,
    );
    await localStore.saveSeasonPreferences(updated);
    _seasonOverride = season;
    notifyListeners();
    await _syncAndroidAppIcon(this.season);
  }

  Future<void> selectDate(DateTime? date) async {
    final updated = SeasonPreferences(
      seasonOverride: _seasonOverride?.name,
      forcedDate: date == null
          ? null
          : DateTime(date.year, date.month, date.day),
    );
    await localStore.saveSeasonPreferences(updated);
    _forcedDate = updated.forcedDate;
    notifyListeners();
    await _syncAndroidAppIcon(season);
  }

  Future<void> reset() async {
    await localStore.saveSeasonPreferences(const SeasonPreferences());
    _seasonOverride = null;
    _forcedDate = null;
    notifyListeners();
    await _syncAndroidAppIcon(season);
  }

  Future<void> _syncAndroidAppIcon(AppSeason season) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _appIconChannel.invokeMethod<void>('setSeasonIcon', {
      'season': season.name,
    });
  }

  AppSeason? _seasonFromName(String? name) {
    if (name == null) return null;
    for (final season in AppSeason.values) {
      if (season.name == name) return season;
    }
    return null;
  }
}
