import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:video_player/video_player.dart';

/// Reproductor de video a pantalla completa.
///
/// Punto 1 - Play/Pause: El toque en el video alterna reproduccion.
///   El icono central de play/pause es controlado desde [VideoScrollableView].
/// Punto 3 - Sonido: Estado de mute expuesto via [isMutedNotifier].
///   El boton de mute esta en la columna lateral ([VideoButtons]).
///
/// Soporta:
///   - Videos locales (assets):  source == VideoSource.local
///   - Videos de red (MP4):      source == VideoSource.pexels | pixabay
class FullScreenPlayer extends StatefulWidget {
  final VideoPost videoPost;

  /// Notifier que expone si el video esta muteado (true = mudo).
  final ValueNotifier<bool> isMutedNotifier;

  /// Notifier que expone si el video esta reproduciendo.
  final ValueNotifier<bool> isPlayingNotifier;

  /// Evita inicializar o reproducir videos que no estan en la pagina activa.
  final bool isActive;

  const FullScreenPlayer({
    super.key,
    required this.videoPost,
    required this.isMutedNotifier,
    required this.isPlayingNotifier,
    this.isActive = true,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _playbackError;

  @override
  void initState() {
    super.initState();
    widget.isMutedNotifier.addListener(_onMuteChanged);
    widget.isPlayingNotifier.addListener(_onPlayingChanged);
    if (widget.isActive) _initController();
  }

  @override
  void didUpdateWidget(covariant FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    if (!widget.isActive) {
      if (_initialized) _controller?.pause();
    } else if (_controller == null && _playbackError == null) {
      _initController();
    } else {
      _syncPlayback();
    }
  }

  Future<void> _initController() async {
    if (!widget.isActive || _controller != null) return;
    final url = widget.videoPost.videoUrl;
    final controller = widget.videoPost.source == VideoSource.local
        ? VideoPlayerController.asset(url)
        : VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    try {
      await controller.setVolume(widget.isMutedNotifier.value ? 0 : 1);
      await controller.setLooping(true);
      await controller.initialize();
      if (!mounted) return;
      setState(() => _initialized = true);
      if (widget.isActive && widget.isPlayingNotifier.value) {
        await controller.play();
      }
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Video playback failed for ${widget.videoPost.id}: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() => _playbackError = 'No se pudo reproducir este video.');
      }
    }
  }

  void _onMuteChanged() {
    if (!mounted || !_initialized || !widget.isActive) return;
    _controller?.setVolume(widget.isMutedNotifier.value ? 0 : 1);
  }

  void _onPlayingChanged() {
    if (!mounted || !_initialized || !widget.isActive) return;
    _syncPlayback();
  }

  void _syncPlayback() {
    final controller = _controller;
    if (controller == null || !_initialized || !widget.isActive) return;
    if (widget.isPlayingNotifier.value) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  @override
  void dispose() {
    widget.isMutedNotifier.removeListener(_onMuteChanged);
    widget.isPlayingNotifier.removeListener(_onPlayingChanged);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    widget.isPlayingNotifier.value = !widget.isPlayingNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      if (_playbackError != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(
                _playbackError!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: Stack(
            children: [
              VideoPlayer(_controller!),
              VideoBackground(stops: const [0.8, 1.0]),
            ],
          ),
        ),
      ),
    );
  }
}
