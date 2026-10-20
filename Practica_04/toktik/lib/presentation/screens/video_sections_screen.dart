import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/providers/video_source_provider.dart';
import 'package:toktik/presentation/screens/discover/discover_screen.dart';
import 'package:toktik/presentation/widgets/video_source_settings_dialog.dart';
import 'package:toktik/shared/audio/season_audio_player.dart';

class VideoSectionsScreen extends StatefulWidget {
  const VideoSectionsScreen({super.key});

  @override
  State<VideoSectionsScreen> createState() => _VideoSectionsScreenState();
}

class _VideoSectionsScreenState extends State<VideoSectionsScreen> {
  final PageController _pageController = PageController();
  final SeasonAudioPlayer _seasonAudioPlayer = SeasonAudioPlayer();
  int _selectedIndex = 0;
  bool _sourceListenerAttached = false;
  SeasonProvider? _seasonProvider;
  AppSeason? _lastSeason;

  static const _titles = ['Discover', 'For You', 'Favorites'];

  @override
  void dispose() {
    context.read<VideoSourceProvider>().removeListener(_showSourceNotice);
    _seasonProvider?.removeListener(_playSeasonChangeAudio);
    unawaited(_seasonAudioPlayer.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final seasonProvider = context.read<SeasonProvider>();
    if (_seasonProvider != seasonProvider) {
      _seasonProvider?.removeListener(_playSeasonChangeAudio);
      _seasonProvider = seasonProvider;
      _lastSeason = seasonProvider.season;
      seasonProvider.addListener(_playSeasonChangeAudio);
    }
    if (!_sourceListenerAttached) {
      context.read<VideoSourceProvider>().addListener(_showSourceNotice);
      _sourceListenerAttached = true;
    }
  }

  void _playSeasonChangeAudio() {
    final season = _seasonProvider?.season;
    if (season == null || season == _lastSeason) return;
    _lastSeason = season;
    unawaited(_seasonAudioPlayer.play(season));
  }

  void _showSourceNotice() {
    final provider = context.read<VideoSourceProvider>();
    final notice = provider.notice;
    if (notice == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(notice)));
      provider.clearNotice();
    });
  }

  Future<void> _openSeasonSettings() async {
    final provider = context.read<SeasonProvider>();
    await showDialog<void>(
      context: context,
      builder: (context) => _SeasonSettingsDialog(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    final sourceProvider = context.watch<VideoSourceProvider>();
    final seasonIcon = switch (season) {
      AppSeason.halloween => Icons.nightlight_round,
      AppSeason.christmas => Icons.ac_unit,
      AppSeason.valentines => Icons.favorite,
      AppSeason.normal => Icons.auto_awesome,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        leading: Icon(seasonIcon),
        actions: [
          IconButton(
            tooltip: 'Tema y modo de prueba',
            onPressed: _openSeasonSettings,
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Fuente de videos: ${sourceProvider.mode.label}',
            onPressed: _openVideoSourceSettings,
            icon: const Icon(Icons.cloud_queue),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) {
            context.read<FavoritesProvider>().loadNextPage();
          }
        },
        children: [
          DiscoverScreen(isVisible: _selectedIndex == 0),
          ForYouScreen(isVisible: _selectedIndex == 1),
          FavoritesScreen(isVisible: _selectedIndex == 2),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'For You',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Future<void> _openVideoSourceSettings() async {
    final provider = context.read<VideoSourceProvider>();
    final previousMode = provider.mode;
    await showDialog<void>(
      context: context,
      builder: (context) => VideoSourceSettingsDialog(provider: provider),
    );
    if (!mounted || provider.mode == previousMode) return;
    await Future.wait([
      context.read<DiscoverProvider>().reload(),
      context.read<ForYouProvider>().reload(),
    ]);
  }
}

class _SeasonSettingsDialog extends StatefulWidget {
  const _SeasonSettingsDialog({required this.provider});

  final SeasonProvider provider;

  @override
  State<_SeasonSettingsDialog> createState() => _SeasonSettingsDialogState();
}

class _SeasonSettingsDialogState extends State<_SeasonSettingsDialog> {
  bool _saving = false;

  Future<void> _selectDate() async {
    try {
      final now = DateTime.now();
      final selected = await showDatePicker(
        context: context,
        initialDate: widget.provider.forcedDate ?? now,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        helpText: 'Forzar fecha para probar el tema',
      );
      if (selected != null) await widget.provider.selectDate(selected);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo guardar la fecha o actualizar el icono: $error',
            ),
          ),
        );
      }
    }
  }

  Future<void> _reset() async {
    setState(() => _saving = true);
    try {
      await widget.provider.reset();
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo restablecer el tema o actualizar el icono: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tema de temporada'),
      content: Consumer<SeasonProvider>(
        builder: (context, provider, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<AppSeason?>(
              initialValue: provider.seasonOverride,
              decoration: const InputDecoration(labelText: 'Temporada manual'),
              items: [
                const DropdownMenuItem<AppSeason?>(
                  value: null,
                  child: Text('Automática por fecha'),
                ),
                ...AppSeason.values.map(
                  (season) => DropdownMenuItem<AppSeason?>(
                    value: season,
                    child: Text(season.label),
                  ),
                ),
              ],
              onChanged: (season) async {
                setState(() => _saving = true);
                try {
                  await provider.selectSeason(season);
                } on Object catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No se pudo guardar la temporada o actualizar el icono: $error',
                        ),
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _saving = false);
                }
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                provider.forcedDate == null
                    ? 'Forzar una fecha...'
                    : 'Fecha: ${MaterialLocalizations.of(context).formatMediumDate(provider.forcedDate!)}',
              ),
            ),
            if (provider.forcedDate != null)
              TextButton(
                onPressed: () => provider.selectDate(null),
                child: const Text('Quitar fecha forzada'),
              ),
            if (_saving) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text('Tema activo: ${provider.season.label}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : _reset,
          child: const Text('Restablecer'),
        ),
        FilledButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Listo'),
        ),
      ],
    );
  }
}
