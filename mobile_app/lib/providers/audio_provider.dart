// =============================================================================
// AeroYield — Audio Provider
// Wraps the audioplayers package to expose play / pause / seek / stop with
// reactive position, duration, and completion state for the UI layer.
// =============================================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  // State
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _currentUrl;

  // ── Public getters ──────────────────────────────────────────────────────
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get currentUrl => _currentUrl;

  /// Normalized progress (0.0 – 1.0) for sliders / progress bars.
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  // ── Constructor ─────────────────────────────────────────────────────────
  AudioProvider() {
    // Keep source loaded after stop so replays are instant.
    _player.setReleaseMode(ReleaseMode.stop);

    // Track playback position changes.
    _player.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // Track total duration once the source is decoded.
    _player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    // Detect playback completion to reset UI state.
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    });
  }

  // ── Controls ────────────────────────────────────────────────────────────

  /// Load [url] if needed, then start or resume playback.
  Future<void> play(String url) async {
    try {
      if (_currentUrl != url) {
        await _player.stop();
        await _player.setSourceUrl(url);
        _currentUrl = url;
        _position = Duration.zero;
      }
      await _player.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AudioProvider.play error: $e');
    }
  }

  /// Pause the current playback.
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Toggle between play and pause.
  Future<void> togglePlayPause(String url) async {
    if (_isPlaying) {
      await pause();
    } else {
      await play(url);
    }
  }

  /// Seek to an absolute [position].
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _position = position;
    notifyListeners();
  }

  /// Stop playback and reset position.
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _position = Duration.zero;
    notifyListeners();
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
