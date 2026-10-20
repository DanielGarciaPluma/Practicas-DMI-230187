import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/infrastructure/datasources/shared_preferences_video_store.dart';
import 'package:toktik/infrastructure/repositories/video_posts_repository_impl.dart';

enum VideoSourceMode { random, coverr, pixabay, internetArchive, local }

extension VideoSourceModeLabel on VideoSourceMode {
  String get label => switch (this) {
        VideoSourceMode.random => 'Aleatorio',
        VideoSourceMode.coverr => 'Coverr',
        VideoSourceMode.pixabay => 'Pixabay',
        VideoSourceMode.internetArchive => 'Internet Archive',
        VideoSourceMode.local => 'Local',
      };
}

class VideoSourceProvider extends ChangeNotifier {
  VideoSourceProvider({
    required this.localStore,
    required this.repositories,
    required this.sources,
  });

  final SharedPreferencesVideoStore localStore;
  final List<VideoPostsRepositoryImpl> repositories;
  final Map<VideoSourceMode, VideoPostDatasource> sources;
  VideoSourceMode _mode = VideoSourceMode.random;
  String? _notice;

  VideoSourceMode get mode => _mode;
  String? get notice => _notice;

  Future<void> load() async {
    final saved = await localStore.getVideoSourceMode();
    _mode = VideoSourceMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => VideoSourceMode.random,
    );
    _applyOrder();
  }

  Future<void> select(VideoSourceMode mode) async {
    await localStore.saveVideoSourceMode(mode.name);
    _mode = mode;
    _applyOrder();
    notifyListeners();
  }

  void clearNotice() {
    _notice = null;
    notifyListeners();
  }

  void reportFallback(String message) {
    _notice = message;
    notifyListeners();
  }

  void _applyOrder() {
    final orderedModes = <VideoSourceMode>[
      if (_mode != VideoSourceMode.random) _mode,
      ...VideoSourceMode.values.where(
        (mode) => mode != VideoSourceMode.random && mode != _mode,
      ),
    ];
    if (_mode == VideoSourceMode.random) {
      orderedModes.shuffle(Random());
    }
    for (final repository in repositories) {
      final orderedSources = <VideoPostDatasource>[];
      for (final mode in orderedModes) {
        final source = sources[mode];
        if (source != null) orderedSources.add(source);
      }
      repository.setDataSources(orderedSources);
    }
  }
}
