import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:toktik/config/theme/app_theme.dart';

class SeasonAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  int _playRequest = 0;

  SeasonAudioPlayer() {
    _player.audioCache = AudioCache(prefix: '');
  }

  Future<void> play(AppSeason season) async {
    final request = ++_playRequest;
    try {
      await _player.stop();
      if (request != _playRequest) return;
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.setVolume(0.8);

      final asset = switch (season) {
        AppSeason.halloween => 'lib/assets/audio/Loopmina_Halloween.mp3',
        AppSeason.christmas => 'lib/assets/audio/Loopmina_Navidad.mp3',
        AppSeason.valentines => 'lib/assets/audio/Loopmina_San_Valentin.mp3',
        AppSeason.normal => null,
      };
      if (asset == null) {
        await _player.play(
          BytesSource(
            _makeWav([
              261.63,
              329.63,
              392.00,
              523.25,
              392.00,
              329.63,
              293.66,
              349.23,
              440.00,
              523.25,
              440.00,
              349.23,
            ]),
            mimeType: 'audio/wav',
          ),
        );
      } else {
        await _player.play(AssetSource(asset));
      }
    } on Exception catch (error, stackTrace) {
      debugPrint('Seasonal audio could not play: $error\n$stackTrace');
    }
  }

  Future<void> stop() async {
    _playRequest++;
    try {
      await _player.stop();
    } on Exception catch (error, stackTrace) {
      debugPrint('Seasonal audio could not stop: $error\n$stackTrace');
    }
  }

  Future<void> dispose() => _player.dispose();

  Uint8List _makeWav(List<double> notes) {
    const sampleRate = 22050;
    const samplesPerNote = 6615;
    final sampleCount = samplesPerNote * notes.length;
    final bytes = Uint8List(44 + sampleCount * 2);
    final header = ByteData.sublistView(bytes);
    header
      ..setUint8(0, 0x52)
      ..setUint8(1, 0x49)
      ..setUint8(2, 0x46)
      ..setUint8(3, 0x46)
      ..setUint32(4, bytes.length - 8, Endian.little)
      ..setUint8(8, 0x57)
      ..setUint8(9, 0x41)
      ..setUint8(10, 0x56)
      ..setUint8(11, 0x45)
      ..setUint8(12, 0x66)
      ..setUint8(13, 0x6D)
      ..setUint8(14, 0x74)
      ..setUint8(15, 0x20)
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, 1, Endian.little)
      ..setUint32(24, sampleRate, Endian.little)
      ..setUint32(28, sampleRate * 2, Endian.little)
      ..setUint16(32, 2, Endian.little)
      ..setUint16(34, 16, Endian.little)
      ..setUint8(36, 0x64)
      ..setUint8(37, 0x61)
      ..setUint8(38, 0x74)
      ..setUint8(39, 0x61)
      ..setUint32(40, sampleCount * 2, Endian.little);
    for (var index = 0; index < sampleCount; index++) {
      final note = notes[index ~/ samplesPerNote];
      final notePosition = index % samplesPerNote;
      final fade = math.min(
        1.0,
        math.min(notePosition / 450, (samplesPerNote - notePosition) / 450),
      );
      final wave = math.sin(2 * math.pi * note * index / sampleRate);
      final value = (wave * fade * 10000).round();
      header.setInt16(44 + index * 2, value, Endian.little);
    }
    return bytes;
  }
}
