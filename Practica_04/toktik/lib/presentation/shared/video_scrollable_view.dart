import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/shared/video_buttons.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  const VideoScrollableView({
    super.key,
    required this.videos,
    required this.onLike,
    required this.onLoadMore,
    this.isVisible = true,
    this.emptyMessage = 'Todavía no hay videos en esta sección.',
  });

  final List<VideoPost> videos;
  final Future<void> Function(VideoPost) onLike;
  final Future<void> Function() onLoadMore;
  final bool isVisible;
  final String emptyMessage;

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  final Map<String, VideoPlaybackControls> _controls = {};
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant VideoScrollableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIds = widget.videos.map((video) => video.id).toSet();
    for (final id in _controls.keys.toList()) {
      if (!currentIds.contains(id)) {
        _controls.remove(id)?.dispose();
      }
    }
  }

  @override
  void dispose() {
    for (final controls in _controls.values) {
      controls.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return Center(child: Text(widget.emptyMessage));
    }
    return PageView.builder(
      itemCount: widget.videos.length,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
        if (index >= widget.videos.length - 2) {
          widget.onLoadMore();
        }
      },
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        final controls = _controls.putIfAbsent(video.id, VideoPlaybackControls.new);
        return Stack(
          fit: StackFit.expand,
          children: [
            FullscreenPlayer(
              key: ValueKey('player-${video.id}'),
              video: video,
              controls: controls,
              shouldPlay: widget.isVisible && index == _currentIndex,
            ),
            Positioned(
              bottom: 30,
              right: 20,
              child: VideoButtons(
                video: video,
                controls: controls,
                onLike: widget.onLike,
              ),
            ),
          ],
        );
      },
    );
  }
}
