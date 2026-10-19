import 'package:flutter/material.dart';

class InfiniteScrollScreen extends StatelessWidget {

  static const name = 'infinite_screen';

  const InfiniteScrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll'),
      ),
      body: const Center(
        child: Text('Infinite Scroll Screen'),
      ),
    );
  }
}