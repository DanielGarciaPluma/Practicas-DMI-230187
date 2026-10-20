import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

class VideoPlaybackControls {
  final muted = ValueNotifier<bool>(false);
  final playing = ValueNotifier<bool>(false);
  final audioAvailable = ValueNotifier<bool?>(null);
  Future<void> Function()? _toggleMute;
  Future<void> Function()? _togglePlayback;

  Future<void> toggleMute() async => _toggleMute?.call();

  Future<void> togglePlayback() async => _togglePlayback?.call();

  void dispose() {
    muted.dispose();
    playing.dispose();
    audioAvailable.dispose();
    _toggleMute = null;
    _togglePlayback = null;
  }
}

class FullscreenPlayer extends StatefulWidget {
  const FullscreenPlayer({
    required this.video,
    required this.controls,
    required this.shouldPlay,
    super.key,
  });

  final VideoPost video;
  final VideoPlaybackControls controls;
  final bool shouldPlay;

  @override
  State<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<FullscreenPlayer> {
  VideoPlayerController? _controller;
  late final Future<void> _initializeVideo;

  @override
  void initState() {
    super.initState();
    widget.controls._toggleMute = _toggleMute;
    widget.controls._togglePlayback = _togglePlayback;
    _initializeVideo = _initialize();
  }

  Future<void> _initialize() async {
    final videoUrl = widget.video.videoUrl;
    final isAsset = videoUrl.startsWith('assets/');
    final resolvedUrl = isAsset
        ? null
        : await _resolveDriveVideoUrl(Uri.parse(videoUrl));
    if (!mounted) return;

    final controller = isAsset
        ? VideoPlayerController.asset(videoUrl)
        : VideoPlayerController.networkUrl(resolvedUrl!);
    _controller = controller;
    controller.addListener(_syncControls);

    await controller.initialize();
    await _detectAudioTrack(resolvedUrl?.toString() ?? videoUrl);
    await controller.setLooping(true);
    await controller.setVolume(widget.controls.muted.value ? 0 : 1);
    if (widget.shouldPlay) {
      await controller.play();
    }
  }

  Future<Uri> _resolveDriveVideoUrl(Uri uri) async {
    if (kIsWeb || uri.host != 'drive.google.com') return uri;

    final headResponse = await http.head(uri);
    final contentType = headResponse.headers['content-type'] ?? '';
    if (contentType.startsWith('video/')) return uri;
    if (!contentType.startsWith('text/html')) {
      throw StateError('Google Drive did not return an MP4 video.');
    }

    final warningPage = await http.get(uri);
    final uuid = RegExp(r'<input[^>]*name="uuid"[^>]*value="([^"]+)"')
        .firstMatch(warningPage.body)
        ?.group(1);
    final fileId = uri.queryParameters['id'];
    if (uuid == null || fileId == null) {
      throw StateError('Google Drive did not provide a video download link.');
    }
    return Uri.https('drive.usercontent.google.com', '/download', {
      'id': fileId,
      'export': 'download',
      'confirm': 't',
      'uuid': uuid,
    });
  }

  Future<void> _detectAudioTrack(String videoUrl) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      widget.controls.audioAvailable.value = true;
      return;
    }
    try {
      final hasAudio = await const MethodChannel('toktik/audio')
          .invokeMethod<bool>('hasAudioTrack', {'url': videoUrl});
      widget.controls.audioAvailable.value = hasAudio ?? true;
    } on MissingPluginException {
      widget.controls.audioAvailable.value = true;
    } on PlatformException catch (error) {
      debugPrint('Could not detect video audio track: $error');
      widget.controls.audioAvailable.value = true;
    }
  }

  void _syncControls() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    widget.controls.muted.value = controller.value.volume == 0;
    widget.controls.playing.value = controller.value.isPlaying;
  }

  @override
  void didUpdateWidget(covariant FullscreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (oldWidget.shouldPlay == widget.shouldPlay ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }
    if (widget.shouldPlay) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        widget.controls.audioAvailable.value == false) {
      return;
    }
    final isMuted = controller.value.volume == 0;
    await controller.setVolume(isMuted ? 1 : 0);
    widget.controls.muted.value = !isMuted;
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    widget.controls.playing.value = controller.value.isPlaying;
  }

  @override
  void dispose() {
    final controller = _controller;
    controller?.removeListener(_syncControls);
    if (widget.controls._toggleMute == _toggleMute) {
      widget.controls._toggleMute = null;
      widget.controls._togglePlayback = null;
    }
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideo,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'No se pudo reproducir este video de ${widget.video.source}.\n'
              '${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        final controller = _controller!;
        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: _togglePlayback,
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
            VideoBackground(
              colors: [Colors.transparent, Colors.black87],
              stops: [0.48, 1],
            ),
            ValueListenableBuilder<bool>(
              valueListenable: widget.controls.playing,
              builder: (context, isPlaying, _) => isPlaying
                  ? const SizedBox.shrink()
                  : Center(
                      child: IconButton.filledTonal(
                        tooltip: 'Reproducir',
                        onPressed: _togglePlayback,
                        iconSize: 52,
                        icon: const Icon(Icons.play_arrow),
                      ),
                    ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 88,
              child: _VideoCaption(caption: widget.video.caption),
            ),
          ],
        );
      },
    );
  }
}

class _VideoCaption extends StatefulWidget {
  const _VideoCaption({required this.caption});

  final String caption;

  @override
  State<_VideoCaption> createState() => _VideoCaptionState();
}

class _VideoCaptionState extends State<_VideoCaption> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Colors.white,
      shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.caption, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 2,
        )..layout(maxWidth: constraints.maxWidth);
        final isLong = textPainter.didExceedMaxLines;
        textPainter.dispose();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_expanded)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 170),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Text(widget.caption, style: style),
                ),
              )
            else
              Text(
                widget.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            if (isLong)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(_expanded ? 'menos' : '... más'),
              ),
          ],
        );
      },
    );
  }
}
