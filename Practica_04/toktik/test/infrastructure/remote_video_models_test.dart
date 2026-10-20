import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/infrastructure/models/remote_video_models.dart';

void main() {
  test('Internet Archive mapper builds a direct MP4 URL', () {
    final post = InternetArchiveVideoMapper.fromJson({
      'identifier': 'archive-item',
      'title': 'Test archive video',
      'file_name': 'video.mp4',
      'downloads': '12',
    });

    expect(
      post.videoUrl,
      'https://archive.org/download/archive-item/video.mp4',
    );
    expect(post.source, 'internet_archive');
    expect(post.views, 12);
  });

  test('Internet Archive mapper rejects missing MP4 metadata', () {
    expect(
      () => InternetArchiveVideoMapper.fromJson({
        'identifier': 'archive-item',
        'title': 'Test archive video',
      }),
      throwsA(isA<FormatException>()),
    );
  });
  test('Coverr mapper prefers the full MP4 when it fits mobile dimensions', () {
    final post = CoverrVideoMapper.fromJson({
      'id': 'coverr-1',
      'title': 'Test Coverr video',
      'max_width': 1920,
      'max_height': 1080,
      'urls': {
        'mp4': 'https://storage.coverr.co/videos/full',
        'mp4_preview': 'https://storage.coverr.co/videos/preview',
      },
    });

    expect(post.videoUrl, 'https://storage.coverr.co/videos/full');
    expect(post.source, 'coverr');
  });

  test('Coverr mapper falls back to preview for oversized originals', () {
    final post = CoverrVideoMapper.fromJson({
      'id': 'coverr-2',
      'max_width': 2048,
      'max_height': 1152,
      'urls': {
        'mp4': 'https://cdn.coverr.co/full',
        'mp4_preview': 'https://cdn.coverr.co/preview',
      },
    });

    expect(post.videoUrl, 'https://cdn.coverr.co/preview');
  });

  test('Pixabay mapper prefers a mobile-sized video over 4K', () {
    final post = PixabayVideoMapper.fromJson({
      'id': 42,
      'tags': 'test',
      'videos': {
        'large': {
          'url': 'https://cdn.example/4k.mp4',
          'width': 3840,
          'height': 2160,
        },
        'medium': {
          'url': 'https://cdn.example/hd.mp4',
          'width': 1280,
          'height': 720,
        },
        'small': {
          'url': 'https://cdn.example/sd.mp4',
          'width': 640,
          'height': 360,
        },
      },
    });

    expect(post.videoUrl, 'https://cdn.example/sd.mp4');
  });

  test('Pixabay mapper rejects a vertical video taller than 1920', () {
    expect(
      () => PixabayVideoMapper.fromJson({
        'id': 43,
        'videos': {
          'medium': {
            'url': 'https://cdn.example/vertical.mp4',
            'width': 1440,
            'height': 2560,
          },
        },
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
