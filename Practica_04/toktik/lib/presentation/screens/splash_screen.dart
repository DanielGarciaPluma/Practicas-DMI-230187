import 'dart:async';
import 'package:flutter/material.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/shared/audio/season_audio_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.season,
    required this.onFinished,
    super.key,
  });

  final AppSeason season;
  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SeasonAudioPlayer _seasonAudioPlayer = SeasonAudioPlayer();
  Timer? _timer;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), _finish);
    unawaited(_playSplashAudio());
  }

  Future<void> _playSplashAudio() async {
    await _seasonAudioPlayer.play(widget.season);
  }

  String _seasonAsset(AppSeason season) => switch (season) {
    AppSeason.normal => 'lib/assets/loopmina_normal.png',
    AppSeason.halloween => 'lib/assets/loopmina_halloween.png',
    AppSeason.christmas => 'lib/assets/loopmina_christmas.png',
    AppSeason.valentines => 'lib/assets/loopmina_san valentin.png',
  };

  Future<void> _continue() async {
    // Chrome allows audio started from this button even when autoplay is blocked.
    _timer?.cancel();
    await _playSplashAudio();
    _timer = Timer(const Duration(seconds: 3), _finish);
  }

  void _finish() {
    if (_finishing || !mounted) return;
    _finishing = true;
    unawaited(_seasonAudioPlayer.stop());
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              _seasonAsset(widget.season),
              width: 104,
              height: 104,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text('loopmina', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 20),
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 12),
            TextButton(onPressed: _continue, child: const Text('Continuar')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_seasonAudioPlayer.dispose());
    super.dispose();
  }
}
