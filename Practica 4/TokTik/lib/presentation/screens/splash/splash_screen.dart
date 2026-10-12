import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/presentation/screens/home/home_screen.dart';

/// Pantalla de bienvenida (Splash) que se muestra 3 segundos al iniciar la app.
///
/// - Detecta la temporada activa mediante [AppTheme.currentSeason].
/// - Muestra el logo correspondiente (Halloween, Navidad o Normal).
/// - Reproduce el audio de 3 segundos de la temporada.
/// - Navega automáticamente a [HomeScreen] al finalizar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Animacion de entrada (fade + scale)
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut),
    );

    _animCtrl.forward();

    // Reproducir sonido estacional
    _playSeasonalSound();

    // Navegar a Home tras 3 segundos
    Future.delayed(const Duration(seconds: 3), _navigateToHome);
  }

  Future<void> _playSeasonalSound() async {
    final String? soundAsset = _seasonSoundAsset;
    if (soundAsset == null) return;

    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource(soundAsset));
    } catch (_) {
      // Si el audio falla, la app continua sin problema
    }
  }

  /// Devuelve la ruta relativa del asset de sonido segun la temporada.
  String? get _seasonSoundAsset {
    switch (AppTheme.currentSeason) {
      case AppSeason.halloween:
        return 'sounds/OctubreP4.mpeg';
      case AppSeason.christmas:
        return 'sounds/DiciembreP4.mpeg';
      case AppSeason.valentines:
      case AppSeason.normal:
        return null;
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    _audioPlayer.stop();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (AppTheme.currentSeason) {
      case AppSeason.halloween:
        return const Color(0xFF0D0016);
      case AppSeason.christmas:
        return const Color(0xFF0D0000);
      case AppSeason.valentines:
        return const Color(0xFF14000B);
      case AppSeason.normal:
        return const Color(0xFF0A0A0A);
    }
  }

  Color get _accentColor {
    switch (AppTheme.currentSeason) {
      case AppSeason.halloween:
        return const Color(0xFFFF6B00);
      case AppSeason.christmas:
        return const Color(0xFFFFD700);
      case AppSeason.valentines:
        return const Color(0xFFFF4081);
      case AppSeason.normal:
        return const Color(0xFF1DB954);
    }
  }

  String get _seasonLabel {
    switch (AppTheme.currentSeason) {
      case AppSeason.halloween:
        return '🎃 ¡Feliz Halloween!';
      case AppSeason.christmas:
        return '🎄 ¡Feliz Navidad!';
      case AppSeason.valentines:
        return '💝 ¡Feliz San Valentín!';
      case AppSeason.normal:
        return 'Videos para ti';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _SeasonalBackground(season: AppTheme.currentSeason),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo estacional con glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withValues(alpha: 0.6),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppTheme.currentAppIcon,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 160,
                            height: 160,
                            color: _accentColor.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 80,
                              color: _accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'TokTik',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(color: _accentColor, blurRadius: 16),
                          const Shadow(color: Colors.black87, blurRadius: 6),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _seasonLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: _accentColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Barra de progreso
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white12,
                          color: _accentColor,
                          minHeight: 3,
                        ),
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

// Fondo segun la temporada

class _SeasonalBackground extends StatelessWidget {
  final AppSeason season;
  const _SeasonalBackground({required this.season});

  @override
  Widget build(BuildContext context) {
    switch (season) {
      case AppSeason.halloween:
        return _HalloweenBg();
      case AppSeason.christmas:
        return _ChristmasBg();
      case AppSeason.valentines:
        return _ValentinesBg();
      case AppSeason.normal:
        return _NormalBg();
    }
  }
}

class _ValentinesBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF3B001D),
            Color(0xFF220011),
            Color(0xFF14000B),
          ],
        ),
      ),
    );
  }
}

class _HalloweenBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF2D1B4E),
            Color(0xFF1A0A2E),
            Color(0xFF0D0016),
          ],
        ),
      ),
      child: CustomPaint(painter: _HalloweenParticlesPainter()),
    );
  }
}

class _ChristmasBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF3B0000),
            Color(0xFF1B0000),
            Color(0xFF0D0000),
          ],
        ),
      ),
    );
  }
}

class _NormalBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF121212),
            Color(0xFF0A0A0A),
          ],
        ),
      ),
    );
  }
}

/// Pinta destellos de fondo para Halloween.
class _HalloweenParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF6B00).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final positions = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.1),
      Offset(size.width * 0.05, size.height * 0.75),
      Offset(size.width * 0.9, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.05),
      Offset(size.width * 0.3, size.height * 0.92),
      Offset(size.width * 0.72, size.height * 0.6),
    ];

    for (final pos in positions) {
      canvas.drawCircle(pos, 50, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

