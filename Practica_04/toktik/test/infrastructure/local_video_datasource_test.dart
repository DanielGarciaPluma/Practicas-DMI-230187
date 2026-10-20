import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/infrastructure/datasources/local_video_datasource_impl.dart';

void main() {
  test(
    'returns Drive-hosted videos without requiring bundled assets',
    () async {
      final videos = await LocalVideoDatasource().getTrendingVideosByPage(1);

      expect(videos, hasLength(17));
      expect(
        videos.every(
          (video) =>
              video.videoUrl.startsWith('https://drive.google.com/uc?') &&
              video.videoUrl.contains('export=download&confirm=t&id='),
        ),
        isTrue,
      );
      expect(videos.map((video) => video.id).toSet(), hasLength(17));
    },
  );
}
