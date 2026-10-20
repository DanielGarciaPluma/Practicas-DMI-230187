import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/remote_video_models.dart';

class InternetArchiveVideoDatasource implements VideoPostDatasource {
  const InternetArchiveVideoDatasource({required this.client});

  final http.Client client;

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) =>
      _fetch(page, 'mediatype:movies');

  @override
  Future<List<VideoPost>> getForYouVideosByPage(int page) =>
      _fetch(page, 'mediatype:movies');

  Future<List<VideoPost>> _fetch(int page, String query) async {
    final searchResponse = await client
        .get(
          Uri.https('archive.org', '/advancedsearch.php', {
            'q': query,
            'fl[]': 'identifier,title,description,downloads',
            'rows': '20',
            'page': '${page < 1 ? 1 : page}',
            'output': 'json',
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (searchResponse.statusCode != 200) {
      throw StateError(
        'Internet Archive search returned HTTP ${searchResponse.statusCode}.',
      );
    }
    final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final docs =
        ((searchJson['response'] as Map<String, dynamic>?)?['docs']
            as List<dynamic>?) ??
        const [];
    final posts = <VideoPost>[];
    final metadataRequests = docs.whereType<Map<String, dynamic>>().map(
      (doc) => _loadVideoMetadata(doc),
    );
    for (final post in await Future.wait(metadataRequests)) {
      if (post != null) posts.add(post);
    }
    if (posts.isEmpty) {
      throw const FormatException(
        'Internet Archive returned no playable MP4 videos.',
      );
    }
    return posts;
  }

  Future<VideoPost?> _loadVideoMetadata(Map<String, dynamic> doc) async {
    final identifier = doc['identifier'];
    if (identifier is! String || identifier.isEmpty) return null;
    try {
      final metadataResponse = await client
          .get(Uri.https('archive.org', '/metadata/$identifier'))
          .timeout(const Duration(seconds: 8));
      if (metadataResponse.statusCode != 200) return null;
      final metadata =
          jsonDecode(metadataResponse.body) as Map<String, dynamic>;
      final files = metadata['files'] as List<dynamic>? ?? const [];
      final file = _selectMp4File(files);
      if (file == null) return null;
      return InternetArchiveVideoMapper.fromJson({
        ...doc,
        'file_name': file['name'],
        'file_width': file['width'],
        'file_height': file['height'],
      });
    } on FormatException {
      return null;
    }
  }

  Map<String, dynamic>? _selectMp4File(List<dynamic> files) {
    final candidates = files
        .whereType<Map<String, dynamic>>()
        .where((file) {
          final name = file['name'];
          final format = file['format']?.toString().toLowerCase() ?? '';
          return name is String &&
              name.toLowerCase().endsWith('.mp4') &&
              (format.isEmpty ||
                  format.contains('mpeg4') ||
                  format.contains('h.264') ||
                  format.contains('h264'));
        })
        .where((file) {
          final width = _asInt(file['width']);
          final height = _asInt(file['height']);
          final size = _asInt(file['size']);
          return (width == 0 || width <= 1920) &&
              (height == 0 || height <= 1920) &&
              (size == 0 || size <= 50 * 1024 * 1024);
        })
        .toList();
    candidates.sort((a, b) {
      final aFormat = a['format']?.toString().toLowerCase() ?? '';
      final bFormat = b['format']?.toString().toLowerCase() ?? '';
      final aFormatRank = aFormat.contains('mpeg4') ? 0 : 1;
      final bFormatRank = bFormat.contains('mpeg4') ? 0 : 1;
      if (aFormatRank != bFormatRank) {
        return aFormatRank.compareTo(bFormatRank);
      }
      final aSize = _asInt(a['size']);
      final bSize = _asInt(b['size']);
      return aSize.compareTo(bSize);
    });
    return candidates.isEmpty ? null : candidates.first;
  }

  int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
