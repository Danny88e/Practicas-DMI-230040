import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Reproductor interactivo de YouTube usando youtube_player_flutter.
///
/// Integra:
/// - Control interactivo de Play / Pause mediante botón central y barra inferior.
/// - Detección táctil en todo el cuadro del reproductor.
/// - Control de sonido (Mute / Unmute con volumen al 100%).
/// - Prevención de bloqueos de interfaz mediante gestión limpia del ciclo de vida.
/// - Recuperación y botón de reintento si ocurre algún problema al cargar.
class YoutubePlayerWidget extends StatefulWidget {
  final String videoId;
  final bool autoPlay;

  const YoutubePlayerWidget({
    super.key,
    required this.videoId,
    this.autoPlay = true,
  });

  /// Extrae el ID limpio en caso de que venga una URL completa de YouTube.
  static String cleanVideoId(String input) {
    final trimmed = input.trim();
    if (trimmed.contains('youtube.com') || trimmed.contains('youtu.be')) {
      final extracted = YoutubePlayerController.convertUrlToId(trimmed);
      if (extracted != null && extracted.isNotEmpty) return extracted;
    }
    return trimmed;
  }

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;

  PlayerState _playerState = PlayerState.unknown;
  bool _isMuted = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final cleanId = YoutubePlayerWidget.cleanVideoId(widget.videoId);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: cleanId,
      autoPlay: widget.autoPlay,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        enableJavaScript: true,
        showVideoAnnotations: false,
        playsInline: true,
      ),
    );

    _subscription = _controller.stream.listen(
      (value) {
        if (!mounted) return;
        final newState = value.playerState;
        if (_playerState != newState) {
          setState(() {
            _playerState = newState;
            if (value.hasError) {
              _errorMessage = 'No se pudo reproducir este video de YouTube.';
            } else {
              _errorMessage = null;
            }
          });

          if (newState == PlayerState.playing) {
            _scheduleHideControls();
          } else {
            _cancelHideTimer();
            if (mounted) setState(() => _showControls = true);
          }
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() => _errorMessage = 'Error al comunicar con YouTube.');
        }
      },
    );

    if (widget.autoPlay) {
      _scheduleHideControls();
    }
  }

  void _scheduleHideControls() {
    _cancelHideTimer();
    _hideControlsTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _playerState == PlayerState.playing) {
        setState(() => _showControls = false);
      }
    });
  }

  void _cancelHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_playerState == PlayerState.playing) {
        await _controller.pauseVideo();
        setState(() {
          _playerState = PlayerState.paused;
          _showControls = true;
        });
        _cancelHideTimer();
      } else if (_playerState == PlayerState.ended) {
        await _controller.seekTo(seconds: 0.0, allowSeekAhead: true);
        await _controller.playVideo();
        if (!_isMuted) {
          await _controller.unMute();
          await _controller.setVolume(100);
        }
        setState(() {
          _playerState = PlayerState.playing;
          _showControls = true;
        });
        _scheduleHideControls();
      } else {
        await _controller.playVideo();
        if (!_isMuted) {
          await _controller.unMute();
          await _controller.setVolume(100);
        }
        setState(() {
          _playerState = PlayerState.playing;
          _showControls = true;
        });
        _scheduleHideControls();
      }
    } catch (e) {
      debugPrint('Error en play/pause de YouTube: $e');
    }
  }

  Future<void> _toggleMute() async {
    final nextMuted = !_isMuted;
    setState(() => _isMuted = nextMuted);
    try {
      if (nextMuted) {
        await _controller.mute();
      } else {
        await _controller.unMute();
        await _controller.setVolume(100);
      }
    } catch (e) {
      debugPrint('Error en control de sonido de YouTube: $e');
    }
  }

  Future<void> _restartVideo() async {
    try {
      await _controller.seekTo(seconds: 0.0, allowSeekAhead: true);
      await _controller.playVideo();
      if (!_isMuted) {
        await _controller.unMute();
        await _controller.setVolume(100);
      }
      setState(() {
        _playerState = PlayerState.playing;
        _errorMessage = null;
        _showControls = true;
      });
      _scheduleHideControls();
    } catch (e) {
      debugPrint('Error al reiniciar video de YouTube: $e');
    }
  }

  @override
  void dispose() {
    _cancelHideTimer();
    _subscription?.cancel();
    try {
      _controller.pauseVideo();
      _controller.close();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = _playerState == PlayerState.playing;
    final bool isEnded = _playerState == PlayerState.ended;
    final bool isBuffering = _playerState == PlayerState.buffering;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Reproductor oficial de YouTube iframe ─────────────────────────
          Center(
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),

          // ── 2. Capa táctil transparente para alternar controles ──────────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_showControls && isPlaying) {
                  _togglePlayPause();
                } else {
                  setState(() => _showControls = !_showControls);
                  if (_showControls && isPlaying) {
                    _scheduleHideControls();
                  }
                }
              },
            ),
          ),

          // ── 3. Botón central animado Play/Pause/Replay (Estilo TokTik) ────────
          Center(
            child: AnimatedOpacity(
              opacity: (_showControls || !isPlaying) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_showControls && isPlaying,
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? Colors.black.withOpacity(0.45)
                          : Colors.black.withOpacity(0.75),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.85),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: isBuffering
                        ? const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.redAccent,
                              ),
                            ),
                          )
                        : Icon(
                            isEnded
                                ? Icons.replay_rounded
                                : (isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded),
                            color: Colors.white,
                            size: 42,
                          ),
                  ),
                ),
              ),
            ),
          ),

          // ── 4. Botones superiores (Reiniciar + Mute/Sonido) ───────────────────
          Positioned(
            top: 10,
            right: 10,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        tooltip: 'Reiniciar video',
                        onPressed: _restartVideo,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: _isMuted ? Colors.redAccent : Colors.white,
                          size: 20,
                        ),
                        tooltip: _isMuted ? 'Activar sonido' : 'Silenciar video',
                        onPressed: _toggleMute,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 5. Barra inferior con Play/Pause directo y estado de audio ────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                        tooltip: isPlaying ? 'Pausar' : 'Reproducir',
                        onPressed: _togglePlayPause,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPlaying
                            ? 'Reproduciendo'
                            : (isEnded ? 'Finalizado' : 'Pausado'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: _toggleMute,
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          size: 18,
                          color: _isMuted ? Colors.white54 : Colors.greenAccent,
                        ),
                        label: Text(
                          _isMuted ? 'Mudo' : 'Audio ON',
                          style: TextStyle(
                            fontSize: 11,
                            color: _isMuted ? Colors.white54 : Colors.greenAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 6. Capa de error si no se puede reproducir ────────────────────────
          if (_errorMessage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _restartVideo,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

