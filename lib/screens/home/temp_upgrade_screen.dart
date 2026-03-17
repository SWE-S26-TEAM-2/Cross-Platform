import 'package:flutter/material.dart';

class TempUpgradeScreen extends StatelessWidget {
  const TempUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade')),
      body: const Center(child: Text('Upgrade Screen')),
    );
  }
}
