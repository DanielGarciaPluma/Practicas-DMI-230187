import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/remote_video_models.dart';

class CoverrVideoDatasource implements VideoPostDatasource {
  const CoverrVideoDatasource({required this.client, required this.apiKey});

  final http.Client client;
  final String apiKey;

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) =>
      _fetch(page, sort: 'trending');

  @override
  Future<List<VideoPost>> getForYouVideosByPage(int page) =>
      _fetch(page, sort: 'popular');

  Future<List<VideoPost>> _fetch(int page, {required String sort}) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw StateError('COVERR_API_KEY has not been configured.');
    }
    final response = await client
        .get(
          Uri.https('api.coverr.co', '/videos', {
            'api_key': key,
            'page': '${page - 1 < 0 ? 0 : page - 1}',
            'page_size': '15',
            'sort': sort,
            'urls': 'true',
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw StateError('Coverr returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final videos = decoded['hits'] as List<dynamic>? ?? const [];
    final mapped = <VideoPost>[];
    for (final item in videos.whereType<Map<String, dynamic>>()) {
      try {
        mapped.add(CoverrVideoMapper.fromJson(item));
      } on FormatException {
        continue;
      }
    }
    if (mapped.isEmpty) {
      throw const FormatException('Coverr returned no playable videos.');
    }
    return mapped;
  }
}
