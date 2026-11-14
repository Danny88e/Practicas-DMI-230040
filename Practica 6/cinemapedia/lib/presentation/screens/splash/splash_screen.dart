import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  static const name = 'splash-screen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navegar automáticamente después de 2.5 segundos
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/home/0');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Image.asset(
                'assets/logos/Cinemapedia_logo.png',
                height: 120,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.movie_creation_outlined,
                  size: 100,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Text(
                'Cinemapedia 230040',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeIn(
              delay: const Duration(milliseconds: 700),
              child: Text(
                'Luis Daniel Suarez Escamilla',
                style: TextStyle(fontSize: 13, color: Colors.white54),
              ),
            ),
            const SizedBox(height: 40),
            FadeIn(
              delay: const Duration(milliseconds: 900),
              child: CircularProgressIndicator(color: colors.primary, strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
