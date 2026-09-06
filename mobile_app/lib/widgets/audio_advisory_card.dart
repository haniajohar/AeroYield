// =============================================================================
// AeroYield — Audio Advisory Card
// Displays the AI advisory text with a play/pause button and a seekable
// progress slider backed by the AudioProvider.  Theme-aware.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_l10n.dart';
import '../providers/audio_provider.dart';

class AudioAdvisoryCard extends StatelessWidget {
  final String advisoryText;
  final String audioUrl;
  final Locale locale;

  const AudioAdvisoryCard({
    super.key,
    required this.advisoryText,
    required this.audioUrl,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        final isThisTrack = audio.currentUrl == audioUrl;
        final isPlaying = isThisTrack && audio.isPlaying;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.aiAdvisory,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Play button + slider row
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: audioUrl.isEmpty
                            ? null
                            : () => _togglePlay(context, audio),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          elevation: 2,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: (isThisTrack ? audio.progress : 0.0).clamp(
                          0.0,
                          1.0,
                        ),
                        onChanged: (v) {
                          if (audio.duration.inMilliseconds > 0 &&
                              isThisTrack) {
                            final pos = Duration(
                              milliseconds: (v * audio.duration.inMilliseconds)
                                  .round(),
                            );
                            audio.seek(pos);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Advisory text
                Text(
                  advisoryText,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _togglePlay(BuildContext context, AudioProvider audio) async {
    try {
      await audio.togglePlayPause(audioUrl);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Audio playback error: $e')));
      }
    }
  }
}
