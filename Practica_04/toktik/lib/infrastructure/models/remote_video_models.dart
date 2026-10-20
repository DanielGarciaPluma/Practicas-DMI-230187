import 'package:toktik/domain/entities/video_post.dart';

class CoverrVideoMapper {
  const CoverrVideoMapper._();

  static VideoPost fromJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>? ?? const {};
    final fullUrl = urls['mp4'];
    final previewUrl = urls['mp4_preview'];
    final fullIsValid = fullUrl is String && fullUrl.startsWith('https://');
    final previewIsValid =
        previewUrl is String && previewUrl.startsWith('https://');
    if (!fullIsValid && !previewIsValid) {
      throw const FormatException('Coverr video has no playable MP4 file.');
    }
    final width = (json['max_width'] as num?)?.toInt() ?? 0;
    final height = (json['max_height'] as num?)?.toInt() ?? 0;
    final useFullUrl =
        fullIsValid &&
        (width == 0 || width <= 1920) &&
        (height == 0 || height <= 1920);
    final playableUrl = useFullUrl ? fullUrl : previewUrl;
    return VideoPost(
      id: 'coverr-${json['id']}',
      caption: json['title'] as String? ?? 'Video de Coverr',
      videoUrl: playableUrl as String,
      likes: 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      source: 'coverr',
    );
  }
}

class PixabayVideoMapper {
  const PixabayVideoMapper._();

  static VideoPost fromJson(Map<String, dynamic> json) {
    final videoFiles = json['videos'] as Map<String, dynamic>? ?? const {};
    final playableUrl = _findPixabayPlayableUrl(videoFiles);
    if (playableUrl == null) {
      throw const FormatException('Pixabay video has no playable MP4 file.');
    }
    return VideoPost(
      id: 'pixabay-${json['id']}',
      caption: (json['tags'] as String?)?.trim().isNotEmpty == true
          ? json['tags'] as String
          : 'Video de Pixabay',
      videoUrl: playableUrl,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      source: 'pixabay',
    );
  }
}

String? _findPixabayPlayableUrl(Map<String, dynamic> videos) {
  for (final quality in ['small', 'medium']) {
    final file = videos[quality];
    if (file is! Map<String, dynamic>) continue;
    final width = (file['width'] as num?)?.toInt();
    final height = (file['height'] as num?)?.toInt();
    final url = file['url'];
    if (width != null &&
        height != null &&
        width <= 1920 &&
        height <= 1920 &&
        url is String &&
        url.startsWith('https://') &&
        url.contains('.mp4')) {
      return url;
    }
  }
  return null;
}

class InternetArchiveVideoMapper {
  const InternetArchiveVideoMapper._();

  static VideoPost fromJson(Map<String, dynamic> json) {
    final identifier = json['identifier'] as String?;
    final fileName = json['file_name'] as String?;
    if (identifier == null || fileName == null || fileName.isEmpty) {
      throw const FormatException('Internet Archive video has no MP4 file.');
    }
    return VideoPost(
      id: 'archive-$identifier',
      caption: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Video de Internet Archive',
      videoUrl: Uri.https(
        'archive.org',
        '/download/$identifier/$fileName',
      ).toString(),
      likes: 0,
      views: _asInt(json['downloads']),
      source: 'internet_archive',
    );
  }

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
