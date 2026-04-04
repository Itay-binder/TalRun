import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talrun/state/app_state.dart';
import 'package:talrun/state/user_role.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('תכנית')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            app.role == UserRole.coach
                ? 'ממשק מאמן: ניהול תכניות למתאמנים — בקרוב.'
                : app.hasActivePlan
                    ? 'תצוגת התכנית האישית — MVP (נתונים יגיעו מ-Firestore).'
                    : 'אין תכנית פעילה. צור תכנית או בקש מהמאמן שלך.',
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.4),
          ),
        ),
      ),
    );
  }
}
