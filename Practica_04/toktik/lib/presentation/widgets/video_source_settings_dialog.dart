import 'package:flutter/material.dart';
import 'package:toktik/presentation/providers/video_source_provider.dart';

class VideoSourceSettingsDialog extends StatefulWidget {
  const VideoSourceSettingsDialog({required this.provider, super.key});

  final VideoSourceProvider provider;

  @override
  State<VideoSourceSettingsDialog> createState() =>
      _VideoSourceSettingsDialogState();
}

class _VideoSourceSettingsDialogState extends State<VideoSourceSettingsDialog> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fuente de videos'),
      content: DropdownButtonFormField<VideoSourceMode>(
        initialValue: widget.provider.mode,
        decoration: const InputDecoration(
          labelText: 'Fuente preferida',
          helperText: 'Si falla, se probarán las demás fuentes.',
        ),
        items: VideoSourceMode.values
            .map(
              (mode) => DropdownMenuItem(value: mode, child: Text(mode.label)),
            )
            .toList(),
        onChanged: _saving
            ? null
            : (mode) async {
                if (mode == null) return;
                setState(() => _saving = true);
                try {
                  await widget.provider.select(mode);
                } finally {
                  if (mounted) setState(() => _saving = false);
                }
              },
      ),
      actions: [
        if (_saving)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        FilledButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Listo'),
        ),
      ],
    );
  }
}
