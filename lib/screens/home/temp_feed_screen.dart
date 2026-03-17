import 'package:flutter/material.dart';

class TempFeedScreen extends StatelessWidget {
  const TempFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: const Center(child: Text('Feed Screen')),
    );
  }
}
