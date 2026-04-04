import 'package:flutter/material.dart';

/// MVP: חיבור אפליקציות (סטרבה, גרמין, אפל ווטש, סונטו) — בעתיד OAuth / deep links.
class ConnectedAppsScreen extends StatelessWidget {
  const ConnectedAppsScreen({super.key});

  static const _apps = [
    _AppItem('Strava', 'סטרבה', Icons.directions_run),
    _AppItem('Garmin', 'גרמין', Icons.watch),
    _AppItem('Apple Watch', 'Apple Watch', Icons.apple),
    _AppItem('Suunto', 'סונטו', Icons.explore_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('חיבור אפליקציות')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _apps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final a = _apps[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: Icon(a.icon, color: Colors.black87),
              ),
              title: Text(a.nameHe),
              subtitle: Text(a.nameEn),
              trailing: FilledButton.tonal(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('חיבור ל-${a.nameHe} — בקרוב')),
                  );
                },
                child: const Text('חבר'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppItem {
  const _AppItem(this.nameEn, this.nameHe, this.icon);

  final String nameEn;
  final String nameHe;
  final IconData icon;
}
