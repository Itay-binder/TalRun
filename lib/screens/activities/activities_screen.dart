import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('פעילות')),
      body: const Center(
        child: Text('היסטוריית אימונים והתקדמות — MVP'),
      ),
    );
  }
}
