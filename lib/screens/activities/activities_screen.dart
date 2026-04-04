import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talrun/screens/activities/activities_performance_tab.dart';
import 'package:talrun/screens/activities/activities_workouts_tab.dart';
import 'package:talrun/state/app_state.dart';
import 'package:talrun/state/user_role.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.role == UserRole.coach) {
      return const _CoachActivitiesBody();
    }
    return _TraineeActivitiesBody();
  }
}

class _CoachActivitiesBody extends StatelessWidget {
  const _CoachActivitiesBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FC),
      appBar: AppBar(
        title: const Text('פעילות'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'ממשק מאמן: צפייה בפעילויות מתאמנים — בקרוב.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
        ),
      ),
    );
  }
}

class _TraineeActivitiesBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hasPlan = context.watch<AppState>().hasActivePlan;
    final user = FirebaseAuth.instance.currentUser;
    final t = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => context.push('/settings'),
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.deepPurple.shade200,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Text(
                                (user?.displayName ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'פעילות',
                        textAlign: TextAlign.center,
                        style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push('/manual-activity/type'),
                      icon: const Icon(Icons.add),
                      tooltip: 'הוספת פעילות ידנית',
                    ),
                    IconButton(
                      onPressed: () => context.push('/calendar'),
                      icon: const Icon(Icons.calendar_month_outlined),
                      tooltip: 'לוח אימונים',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              TabBar(
                indicatorColor: Colors.black87,
                indicatorWeight: 3,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black45,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(text: 'אימונים שביצעתי'),
                  Tab(text: 'ביצועים'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ActivitiesWorkoutsTab(hasActivePlan: hasPlan),
                    ActivitiesPerformanceTab(hasActivePlan: hasPlan),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
