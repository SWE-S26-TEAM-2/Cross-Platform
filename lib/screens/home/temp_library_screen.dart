import 'package:flutter/material.dart';

class TempLibraryScreen extends StatelessWidget {
  const TempLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: const Center(child: Text('Library Screen')),
    );
  }
}
