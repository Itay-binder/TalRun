import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talrun/screens/activities/manual_activity_kind.dart';

/// בחירת סוג פעילות לפני מסך הפרטים.
class ManualActivityTypeScreen extends StatelessWidget {
  const ManualActivityTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('הוספת פעילות')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'בחרו סוג פעילות',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'לאחר מכן תוכלו למלא מרחק, זמן ופרטים נוספים.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 20),
          ...ManualActivityKind.values.map(
            (k) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(k.icon, color: Colors.black87),
                ),
                title: Text(k.labelHe),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => context.push('/manual-activity/details', extra: k),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
