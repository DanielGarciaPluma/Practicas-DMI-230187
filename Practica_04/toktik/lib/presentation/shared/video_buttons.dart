import 'package:flutter/material.dart';
import 'package:toktik/config/helpers/human_formats.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';

class VideoButtons extends StatelessWidget {
  const VideoButtons({
    required this.video,
    required this.controls,
    required this.onLike,
    super.key,
  });

  final VideoPost video;
  final VideoPlaybackControls controls;
  final Future<void> Function(VideoPost) onLike;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CustomIconButton(
          value: video.likes,
          iconData: video.isLiked ? Icons.favorite : Icons.favorite_border,
          iconColor: video.isLiked ? Colors.redAccent : Colors.white,
          semanticLabel: video.isLiked ? 'Quitar Me gusta' : 'Me gusta',
          onPressed: () async {
            try {
              await onLike(video);
            } catch (error) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No se pudo guardar el Me gusta: $error'),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 20),
        _CustomIconButton(
          value: video.views,
          iconData: Icons.remove_red_eye_outlined,
          semanticLabel: 'Visualizaciones',
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<bool?>(
          valueListenable: controls.audioAvailable,
          builder: (context, audioAvailable, _) => ValueListenableBuilder<bool>(
            valueListenable: controls.muted,
            builder: (context, isMuted, _) => _CustomIconButton(
              iconData: audioAvailable != true || isMuted
                  ? Icons.volume_off
                  : Icons.volume_up,
              iconColor: audioAvailable != true ? Colors.white38 : Colors.white,
              semanticLabel: audioAvailable != true
                  ? 'Audio no disponible'
                  : isMuted
                  ? 'Activar sonido'
                  : 'Silenciar',
              onPressed: audioAvailable != true ? null : controls.toggleMute,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<bool>(
          valueListenable: controls.playing,
          builder: (context, isPlaying, _) => _CustomIconButton(
            iconData: isPlaying ? Icons.pause : Icons.play_arrow,
            semanticLabel: isPlaying ? 'Pausar video' : 'Reanudar video',
            onPressed: controls.togglePlayback,
          ),
        ),
      ],
    );
  }
}

class _CustomIconButton extends StatelessWidget {
  const _CustomIconButton({
    this.value,
    required this.iconData,
    this.iconColor = Colors.white,
    this.semanticLabel,
    this.onPressed,
  });

  final int? value;
  final IconData iconData;
  final Color iconColor;
  final String? semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          tooltip: semanticLabel,
          onPressed: onPressed,
          icon: Icon(iconData, color: iconColor, size: 30),
        ),
        if (value != null && value! > 0)
          Text(HumanFormats.humanReadableNumber(value!.toDouble())),
      ],
    );
  }
}
