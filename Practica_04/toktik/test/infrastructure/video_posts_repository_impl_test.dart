import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/domain/datasources/video_post_local_store.dart';
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/repositories/video_posts_repository_impl.dart';

void main() {
  group('VideoPostsRepositoryImpl', () {
    test('continues to the next datasource after a failure', () async {
      final localStore = _MemoryVideoStore();
      final first = _FakeVideoDatasource(error: StateError('offline'));
      final second = _FakeVideoDatasource(
        posts: [_post('remote', source: 'second')],
      );
      final repository = VideoPostsRepositoryImpl(
        videoDatasources: [first, second],
        localStore: localStore,
      );

      final posts = await repository.getTrendingVideosByPage(1);

      expect(posts.single.id, 'remote');
      expect(first.trendingCalls, 1);
      expect(second.trendingCalls, 1);
    });

    test(
      'persists like state and increments/decrements count by one',
      () async {
        final localStore = _MemoryVideoStore();
        final repository = VideoPostsRepositoryImpl(
          videoDatasources: [_FakeVideoDatasource()],
          localStore: localStore,
        );
        final original = _post('saved', likes: 3);

        final liked = await repository.toggleLike(original);
        final unliked = await repository.toggleLike(original);

        expect(liked.likes, 4);
        expect(liked.isLiked, isTrue);
        expect(unliked.likes, 3);
        expect(unliked.isLiked, isFalse);
        expect(localStore.posts['saved']?.isLiked, isFalse);
      },
    );

    test('returns only persisted liked videos in Favorites', () async {
      final localStore = _MemoryVideoStore()
        ..posts['liked'] = _post('liked', isLiked: true)
        ..posts['not-liked'] = _post('not-liked');
      final repository = VideoPostsRepositoryImpl(
        videoDatasources: [_FakeVideoDatasource()],
        localStore: localStore,
      );

      final favorites = await repository.getFavoriteVideosByUser('local-user');

      expect(favorites.map((post) => post.id), ['liked']);
    });
  });
}

VideoPost _post(
  String id, {
  int likes = 0,
  bool isLiked = false,
  String source = 'test',
}) {
  return VideoPost(
    id: id,
    caption: id,
    videoUrl: 'https://videos.example/$id.mp4',
    likes: likes,
    isLiked: isLiked,
    source: source,
  );
}

class _FakeVideoDatasource implements VideoPostDatasource {
  _FakeVideoDatasource({this.posts = const [], this.error});

  final List<VideoPost> posts;
  final Object? error;
  int trendingCalls = 0;

  @override
  Future<List<VideoPost>> getForYouVideosByPage(int page) async => _load();

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    trendingCalls++;
    return _load();
  }

  Future<List<VideoPost>> _load() async {
    if (error case final error?) throw error;
    return posts;
  }
}

class _MemoryVideoStore implements VideoPostLocalStore {
  final Map<String, VideoPost> posts = {};
  String? videoSourceMode;

  @override
  Future<Map<String, VideoPost>> getSavedPosts() async => {...posts};

  @override
  Future<void> savePost(VideoPost post) async {
    posts[post.id] = post;
  }

  @override
  Future<SeasonPreferences> getSeasonPreferences() async =>
      const SeasonPreferences();

  @override
  Future<void> saveSeasonPreferences(SeasonPreferences preferences) async {}
  
  @override
  Future<String?> getVideoSourceMode() async => videoSourceMode;

  @override
  Future<void> saveVideoSourceMode(String mode) async {
    videoSourceMode = mode;
  }
}
