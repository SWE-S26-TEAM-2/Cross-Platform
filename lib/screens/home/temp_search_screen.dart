import 'package:flutter/material.dart';

class TempSearchScreen extends StatelessWidget {
  const TempSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('Search Screen')),
    );
  }
}
