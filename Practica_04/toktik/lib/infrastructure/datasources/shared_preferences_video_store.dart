import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/datasources/video_post_local_store.dart';
import 'package:toktik/domain/entities/video_post.dart';

class SharedPreferencesVideoStore implements VideoPostLocalStore {
  SharedPreferencesVideoStore(this.preferences);

  final SharedPreferences preferences;

  static const _savedPostsKey = 'toktik.saved_posts';
  static const _seasonOverrideKey = 'toktik.season_override';
  static const _forcedDateKey = 'toktik.forced_date';
  static const _videoSourceModeKey = 'toktik.video_source_mode';

  @override
  Future<Map<String, VideoPost>> getSavedPosts() async {
    final encoded = preferences.getString(_savedPostsKey);
    if (encoded == null) return {};
    final decoded = jsonDecode(encoded) as Map<String, dynamic>;
    return decoded.map(
      (id, value) =>
          MapEntry(id, VideoPost.fromJson(value as Map<String, dynamic>)),
    );
  }

  @override
  Future<void> savePost(VideoPost post) async {
    final saved = await getSavedPosts();
    saved[post.id] = post;
    final didSave = await preferences.setString(
      _savedPostsKey,
      jsonEncode(saved.map((id, video) => MapEntry(id, video.toJson()))),
    );
    if (!didSave) {
      throw StateError('Could not persist the liked state for ${post.id}.');
    }
  }

  @override
  Future<SeasonPreferences> getSeasonPreferences() async {
    final date = preferences.getString(_forcedDateKey);
    final forcedDate = date == null ? null : DateTime.tryParse(date);
    if (date != null && forcedDate == null) {
      throw const FormatException('Stored forced date is invalid.');
    }
    return SeasonPreferences(
      seasonOverride: preferences.getString(_seasonOverrideKey),
      forcedDate: forcedDate,
    );
  }

  @override
  Future<void> saveSeasonPreferences(
    SeasonPreferences preferencesToSave,
  ) async {
    final season = preferencesToSave.seasonOverride;
    if (season == null) {
      await preferences.remove(_seasonOverrideKey);
    } else {
      final didSave = await preferences.setString(_seasonOverrideKey, season);
      if (!didSave) throw StateError('Could not save the season override.');
    }
    final date = preferencesToSave.forcedDate;
    if (date == null) {
      await preferences.remove(_forcedDateKey);
    } else {
      final didSave = await preferences.setString(
        _forcedDateKey,
        date.toIso8601String(),
      );
      if (!didSave) throw StateError('Could not save the forced test date.');
    }
  }

  @override
  Future<String?> getVideoSourceMode() async =>
      preferences.getString(_videoSourceModeKey);

  @override
  Future<void> saveVideoSourceMode(String mode) async {
    final didSave = await preferences.setString(_videoSourceModeKey, mode);
    if (!didSave) throw StateError('Could not save the video source mode.');
  }
}
