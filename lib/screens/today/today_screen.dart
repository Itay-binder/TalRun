import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talrun/theme/workout_colors.dart';
import 'package:talrun/widgets/weekly_strip.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static const _hasPlan = true;
  static const _weekCurrent = 3;
  static const _weekTotal = 12;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - DateTime.monday));
    final labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final dayNumbers = List.generate(7, (i) => weekStart.add(Duration(days: i)).day);
    final selectedIndex = (now.weekday - DateTime.monday).clamp(0, 6);

    final markers = <List<WorkoutKind>>[
      [WorkoutKind.run, WorkoutKind.strength],
      [],
      [],
      [WorkoutKind.run],
      [WorkoutKind.mobility],
      [WorkoutKind.stretch],
      [WorkoutKind.run],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
                  const Spacer(),
                  if (_hasPlan) ...[
                    Text(
                      'WEEK $_weekCurrent/$_weekTotal',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push('/calendar'),
                      icon: const Icon(Icons.calendar_month_outlined),
                      tooltip: 'לוח אימונים',
                    ),
                  ] else
                    TextButton(
                      onPressed: () {
                        /* TODO: צור תכנית */
                      },
                      child: const Text('צור תכנית'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: WeeklyStrip(
                    labels: labels,
                    dayNumbers: dayNumbers,
                    selectedIndex: selectedIndex,
                    markersByDayIndex: markers,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _hasPlan
                          ? 'מנוחה טובה, ${user?.displayName?.split(' ').first ?? 'רץ'}'
                          : 'עדיין אין תכנית — צור תכנית כדי להתחיל',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (_hasPlan)
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => context.push('/workout/today'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: WorkoutKind.run.color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'אימון היום',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'ריצה קלה • 5 ק״מ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_left),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width - 32,
          child: FilledButton.icon(
            onPressed: () => _showStartSheet(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'התחל אימון',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void _showStartSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('אימון מהתכנית להיום'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/workout/today');
                },
              ),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('אימון חופשי'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/workout/free');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
