import 'package:toktik/presentation/providers/video_feed_provider.dart';

class DiscoverProvider extends VideoFeedProvider {
  DiscoverProvider({required super.videosRepository})
    : super(feed: VideoFeed.discover);
}

class ForYouProvider extends VideoFeedProvider {
  ForYouProvider({required super.videosRepository})
    : super(feed: VideoFeed.forYou);
}

class FavoritesProvider extends VideoFeedProvider {
  FavoritesProvider({required super.videosRepository})
    : super(feed: VideoFeed.favorites);
}
