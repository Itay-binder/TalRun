import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:talrun/data/demo_trainee_plan.dart';
import 'package:talrun/state/app_state.dart';
import 'package:talrun/state/user_role.dart';
import 'package:talrun/theme/workout_colors.dart';
import 'package:talrun/utils/calendar_he.dart';

class TrainingCalendarScreen extends StatelessWidget {
  const TrainingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    if (app.role == UserRole.coach) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('לוח אימונים'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'ממשק מאמן: כאן יוצג לוח לפי מתאמן נבחר.\n'
              'בשלב זה אין עדיין רשימת מתאמנים — נחבר ל-Firestore בהמשך.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.4),
            ),
          ),
        ),
      );
    }

    if (!app.hasActivePlan) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('לוח אימונים'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'אין תכנית פעילה',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'כשתהיה לך תכנית, השבועות והאימונים יופיעו כאן.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54, height: 1.35),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final weekStart = startOfWeekSunday(now);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final rangeLabel =
        '${DateFormat.MMMd('he_IL').format(weekStart)} – ${DateFormat.MMMd('he_IL').format(weekEnd)}';

    final dayRows = List<Widget>.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      final isToday = startOfLocalDay(day) == startOfLocalDay(now);
      final slot = demoSlotBySunDay[i];
      final workouts = slot == null
          ? <_WorkoutCardData>[]
          : [
              _WorkoutCardData(slot.title, slot.subtitle, slot.kind),
            ];

      return _DayRow(
        dayLabel: kHebrewWeekdayShort[i],
        dayNum: day.day,
        highlight: isToday,
        workouts: workouts,
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('לוח אימונים'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('שמור'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WeekBlock(
            rangeLabel: rangeLabel,
            weekLabel: 'שבוע $demoWeekCurrent',
            totalDone: '16.7 ק״מ',
            totalGoal: '19.5 ק״מ',
            days: dayRows,
          ),
          const SizedBox(height: 24),
          Text(
            'גרירה לשינוי ימים — יתווסף בשלב הבא',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black45,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeekBlock extends StatelessWidget {
  const _WeekBlock({
    required this.rangeLabel,
    required this.weekLabel,
    required this.totalDone,
    required this.totalGoal,
    required this.days,
  });

  final String rangeLabel;
  final String weekLabel;
  final String totalDone;
  final String totalGoal;
  final List<Widget> days;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          rangeLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          weekLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'סה״כ: $totalDone / $totalGoal',
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('איפוס'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...days,
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.dayLabel,
    required this.dayNum,
    this.highlight = false,
    required this.workouts,
  });

  final String dayLabel;
  final int dayNum;
  final bool highlight;
  final List<_WorkoutCardData> workouts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  dayLabel,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: highlight ? Colors.black : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: highlight ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: workouts.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'יום מנוחה',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ]
                  : workouts
                      .map(
                        (w) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _WorkoutCard(
                            data: w,
                            onTap: () => context
                                .push('/workout/${w.title.hashCode}'),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCardData {
  const _WorkoutCardData(this.title, this.subtitle, this.kind);

  final String title;
  final String subtitle;
  final WorkoutKind kind;
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.data, required this.onTap});

  final _WorkoutCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: data.kind.color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
