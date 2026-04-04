import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:talrun/state/app_state.dart';
import 'package:talrun/state/user_role.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('הגדרות'),
      ),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? Text((user.displayName ?? '?')[0])
                    : null,
              ),
              title: Text(user.displayName ?? 'משתמש'),
              subtitle: Text(user.email ?? ''),
            ),
          const Divider(),
          const ListTile(
            title: Text('סוג משתמש'),
            subtitle: Text('מאמן רואה ממשק ניהול; מתאמן רואה את התכנית האישית'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<UserRole>(
              segments: UserRole.values
                  .map(
                    (r) => ButtonSegment<UserRole>(
                      value: r,
                      label: Text(r.labelHe),
                    ),
                  )
                  .toList(),
              selected: {app.role},
              onSelectionChanged: (s) {
                if (s.isEmpty) return;
                context.read<AppState>().setRole(s.first);
              },
            ),
          ),
          if (app.role == UserRole.trainee) ...[
            const Divider(),
            SwitchListTile(
              title: const Text('תכנית פעילה (דמו)'),
              subtitle: const Text(
                'כבוי: לוח ריק ואין אימונים. מופעל: נתוני דמו לבדיקת UI. '
                'בפרודקשן יגיע מ-Firestore.',
              ),
              value: app.hasActivePlan,
              onChanged: (v) => context.read<AppState>().setHasActivePlan(v),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('התנתק'),
            onTap: () async {
              await GoogleSignIn.instance.signOut();
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/sign-in');
            },
          ),
        ],
      ),
    );
  }
}
