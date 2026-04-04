import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talrun/data/demo_trainee_plan.dart';
import 'package:talrun/data/plan_weeks_demo.dart';
import 'package:talrun/state/app_state.dart';
import 'package:talrun/state/user_role.dart';
import 'package:talrun/theme/workout_colors.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.role == UserRole.coach) {
      return const _CoachPlanBody();
    }
    if (!app.hasActivePlan) {
      return const _NoPlanBody();
    }
    return const _TraineePlanBody();
  }
}

class _CoachPlanBody extends StatelessWidget {
  const _CoachPlanBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FC),
      appBar: AppBar(
        title: const Text('תכנית'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'ממשק מאמן: ניהול תכניות למתאמנים — בקרוב.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
        ),
      ),
    );
  }
}

class _NoPlanBody extends StatelessWidget {
  const _NoPlanBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FC),
      appBar: AppBar(title: const Text('תכנית')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'אין תכנית פעילה. צור תכנית או בקש מהמאמן שלך.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
        ),
      ),
    );
  }
}

class _TraineePlanBody extends StatefulWidget {
  const _TraineePlanBody();

  @override
  State<_TraineePlanBody> createState() => _TraineePlanBodyState();
}

class _TraineePlanBodyState extends State<_TraineePlanBody> {
  late final Set<int> _expandedWeeks;

  @override
  void initState() {
    super.initState();
    _expandedWeeks = {
      for (final w in buildDemoPlanWeeks())
        if (!w.isLocked) w.weekIndex,
    };
  }

  void _toggleWeek(int weekIndex) {
    setState(() {
      if (_expandedWeeks.contains(weekIndex)) {
        _expandedWeeks.remove(weekIndex);
      } else {
        _expandedWeeks.add(weekIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final weeks = buildDemoPlanWeeks();
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
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
                  Expanded(
                    child: Text(
                      'התכנית',
                      textAlign: TextAlign.center,
                      style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/calendar'),
                    icon: const Icon(Icons.calendar_month_outlined),
                    tooltip: 'לוח אימונים',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'שבוע $demoWeekCurrent מתוך $demoWeekTotal בתכנית',
                textAlign: TextAlign.center,
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanSummaryCard(t: t),
                    const SizedBox(height: 16),
                    _PlanActionRow(
                      onCalendar: () => context.push('/calendar'),
                      onApps: () => context.push('/integrations'),
                      onPace: () => context.push('/pace-insights'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'שבועות אימון',
                      style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    ...weeks.map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PlanWeekCard(
                          week: w,
                          expanded: _expandedWeeks.contains(w.weekIndex),
                          onToggle: () => _toggleWeek(w.weekIndex),
                          onLockedTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'השבוע ייפתח כשיגיע התור בתכנית',
                                ),
                              ),
                            );
                          },
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
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.t});

  final TextTheme t;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kPlanTitleHe,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                  ),
                  child: const Text(
                    'RF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _WeekSegmentsBar(
              total: demoWeekTotal,
              filled: kPlanWeeksCompletedDisplay,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'שבועות הושלמו',
                    value:
                        '$kPlanWeeksCompletedDisplay/$demoWeekTotal',
                  ),
                ),
                Expanded(
                  child: _StatBlock(
                    label: 'מרחק',
                    value:
                        '${kPlanDistanceDoneKm.toStringAsFixed(0)}/${kPlanDistanceGoalKm.toStringAsFixed(1)} ק״מ',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekSegmentsBar extends StatelessWidget {
  const _WeekSegmentsBar({required this.total, required this.filled});

  final int total;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i < filled;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: done ? Colors.black87 : Colors.grey.shade300,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.labelSmall?.copyWith(color: Colors.black45),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _PlanActionRow extends StatelessWidget {
  const _PlanActionRow({
    required this.onCalendar,
    required this.onApps,
    required this.onPace,
  });

  final VoidCallback onCalendar;
  final VoidCallback onApps;
  final VoidCallback onPace;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _RoundAction(
              icon: Icons.calendar_month_outlined,
              label: 'סידור אימונים',
              onTap: onCalendar,
            ),
            _RoundAction(
              icon: Icons.apps,
              label: 'חיבור אפליקציות',
              onTap: onApps,
            ),
            _RoundAction(
              icon: Icons.speed_outlined,
              label: 'תובנות קצב',
              onTap: onPace,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
              child: Icon(icon, color: Colors.black87, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanWeekCard extends StatelessWidget {
  const _PlanWeekCard({
    required this.week,
    required this.expanded,
    required this.onToggle,
    required this.onLockedTap,
  });

  final PlanWeekData week;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onLockedTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    if (week.isLocked) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        child: InkWell(
          onTap: onLockedTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'שבוע ${week.weekIndex}',
                        style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        week.rangeLabelHe(),
                        style: t.bodySmall?.copyWith(color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 28),
              ],
            ),
          ),
        ),
      );
    }

    final n = week.workouts.length;
    final done = week.workoutsDone;

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: week.isCurrent
            ? const BorderSide(color: Colors.black87, width: 2)
            : BorderSide.none,
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'שבוע ${week.weekIndex}',
                            style:
                                t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (week.isCompleted)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 22,
                          )
                        else
                          Icon(
                            expanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.black45,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      week.rangeLabelHe(),
                      style: t.bodySmall?.copyWith(color: Colors.black45),
                    ),
                    const SizedBox(height: 12),
                    _WeekSegmentsBar(total: n, filled: done),
                    const SizedBox(height: 10),
                    Text(
                      'אימונים: $done/$n • מרחק: ${week.kmDone.toStringAsFixed(2)}/${week.kmGoal.toStringAsFixed(2)} ק״מ',
                      style: t.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: week.workouts
                      .map((e) => _WorkoutLine(entry: e))
                      .toList(),
                ),
              ),
          ],
        ),
    );
  }
}

class _WorkoutLine extends StatelessWidget {
  const _WorkoutLine({required this.entry});

  final PlanWorkoutEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            entry.completed ? Icons.check_circle : Icons.crop_square,
            size: 20,
            color: entry.completed ? entry.kind.color : Colors.grey.shade400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.dayLabel}: ${entry.title}',
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (entry.detail != null && entry.detail!.isNotEmpty)
                  Text(
                    entry.detail!,
                    style: t.bodySmall?.copyWith(color: Colors.black45),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
