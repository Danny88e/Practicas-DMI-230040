import 'package:flutter/material.dart';

class AnimatedScreen extends StatelessWidget {

  static const name = 'animated_screen';

  const AnimatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Container'),
      ),
      body: const Center(
        child: Text('Animated Screen'),
      ),
    );
  }
}