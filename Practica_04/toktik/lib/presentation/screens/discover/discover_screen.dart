import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/video_feed_provider.dart';
import 'package:toktik/presentation/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key, this.isVisible = true});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return _VideoFeedBody<DiscoverProvider>(
      title: 'Discover',
      isVisible: isVisible,
    );
  }
}

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key, this.isVisible = true});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return _VideoFeedBody<ForYouProvider>(
      title: 'For You',
      isVisible: isVisible,
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.isVisible = true});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return _VideoFeedBody<FavoritesProvider>(
      title: 'Favorites',
      isVisible: isVisible,
      emptyMessage: 'Guarda tus videos favoritos con el corazón.',
    );
  }
}

class _VideoFeedBody<T extends VideoFeedProvider> extends StatelessWidget {
  const _VideoFeedBody({
    required this.title,
    required this.isVisible,
    this.emptyMessage,
  });

  final String title;
  final bool isVisible;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<T>();
    if (provider.initialLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (provider.videos.isEmpty && provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No se pudo cargar $title.\n${provider.errorMessage}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: provider.loadNextPage,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    return VideoScrollableView(
      videos: provider.videos,
      onLike: provider.toggleLike,
      onLoadMore: provider.loadNextPage,
      isVisible: isVisible,
      emptyMessage: emptyMessage ?? 'No hay videos disponibles.',
    );
  }
}
