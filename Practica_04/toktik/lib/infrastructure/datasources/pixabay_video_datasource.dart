import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/remote_video_models.dart';

class PixabayVideoDatasource implements VideoPostDatasource {
  const PixabayVideoDatasource({
    required this.client,
    required this.apiKey,
  });

  final http.Client client;
  final String apiKey;

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) =>
      _fetch(page, 'trending');

  @override
  Future<List<VideoPost>> getForYouVideosByPage(int page) =>
      _fetch(page, 'vertical');

  Future<List<VideoPost>> _fetch(int page, String query) async {
    if (apiKey.isEmpty) {
      throw StateError('PIXABAY_API_KEY has not been configured.');
    }
    final response = await client
        .get(
          Uri.https('pixabay.com', '/api/videos/', {
            'key': apiKey,
            'q': query,
            'page': '$page',
            'per_page': '15',
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw StateError('Pixabay returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final videos = decoded['hits'] as List<dynamic>? ?? const [];
    final mapped = <VideoPost>[];
    for (final item in videos.whereType<Map<String, dynamic>>()) {
      try {
        mapped.add(PixabayVideoMapper.fromJson(item));
      } on FormatException {
        continue;
      }
    }
    if (mapped.isEmpty) {
      throw const FormatException('Pixabay returned no playable videos.');
    }
    return mapped;
  }
}
