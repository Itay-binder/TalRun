import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:talrun/data/activities_demo.dart';
import 'package:talrun/data/calendar_workout_routes.dart';
import 'package:talrun/data/plan_weeks_demo.dart';
import 'package:talrun/theme/workout_colors.dart';

/// פירוט אימון: פעילות שבוצעה, פריט מתכנית, או פריט מלוח (דמו; בעתיד Firestore).
class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context) {
    final direct = demoActivityById(workoutId);
    if (direct != null) {
      return _WorkoutActivityScaffold(activity: direct);
    }

    final plan = tryParsePlanWorkoutRouteId(workoutId);
    if (plan != null) {
      final e = plan.entry;
      if (e.completed && e.completedActivityId != null) {
        final linked = demoActivityById(e.completedActivityId!);
        if (linked != null) {
          return _WorkoutActivityScaffold(activity: linked);
        }
      }
      return _WorkoutPlanEntryScaffold(parsed: plan);
    }

    final cal = tryGetCalendarWorkoutRoute(workoutId);
    if (cal != null) {
      if (cal.completedActivityId != null) {
        final linked = demoActivityById(cal.completedActivityId!);
        if (linked != null) {
          return _WorkoutActivityScaffold(activity: linked);
        }
      }
      return _WorkoutCalendarSlotScaffold(info: cal);
    }

    return _WorkoutNotFoundScaffold(workoutId: workoutId);
  }
}

class _WorkoutNotFoundScaffold extends StatelessWidget {
  const _WorkoutNotFoundScaffold({required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('אימון'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'לא נמצא אימון עם המזהה הזה.',
                textAlign: TextAlign.center,
                style: t.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(
                workoutId,
                style: t.bodySmall?.copyWith(color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutActivityScaffold extends StatelessWidget {
  const _WorkoutActivityScaffold({required this.activity});

  final DemoActivity activity;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final dateLine =
        '${DateFormat.EEEE('he_IL').format(activity.start)} · '
        '${DateFormat.yMMMd('he_IL').format(activity.start)} · '
        '${DateFormat.Hm('he_IL').format(activity.start)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('פירוט אימון'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AccentBar(color: activity.accent),
            const SizedBox(height: 16),
            Text(
              activity.title,
              style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              dateLine,
              style: t.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    if (activity.hasDistance) ...[
                      _StatTile(
                        icon: Icons.straighten,
                        label: 'מרחק',
                        value: '${activity.distanceKm.toStringAsFixed(2)} ק״מ',
                      ),
                      const Divider(height: 1),
                    ],
                    _StatTile(
                      icon: Icons.timer_outlined,
                      label: 'משך',
                      value: formatDurationHe(activity.duration),
                    ),
                    if (activity.hasDistance && activity.avgPaceSecPerKm > 0) ...[
                      const Divider(height: 1),
                      _StatTile(
                        icon: Icons.speed,
                        label: 'קצב ממוצע',
                        value: formatPaceHe(activity.avgPaceSecPerKm),
                      ),
                    ],
                    if (activity.avgHeartRate != null) ...[
                      const Divider(height: 1),
                      _StatTile(
                        icon: Icons.favorite_outline,
                        label: 'דופק ממוצע',
                        value: '${activity.avgHeartRate} bpm',
                      ),
                    ],
                    if (activity.calories != null) ...[
                      const Divider(height: 1),
                      _StatTile(
                        icon: Icons.local_fire_department_outlined,
                        label: 'קלוריות (משוער)',
                        value: '${activity.calories}',
                      ),
                    ],
                    if (activity.hasDistance &&
                        activity.elevationGainM != null) ...[
                      const Divider(height: 1),
                      _StatTile(
                        icon: Icons.terrain_outlined,
                        label: 'עלייה מצטברת',
                        value: '${activity.elevationGainM} מ׳',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: activity.accent.withValues(alpha: 0.15),
                  child: Icon(Icons.cloud_outlined, color: activity.accent),
                ),
                title: const Text('מקור הנתונים'),
                subtitle: Text(activity.source),
              ),
            ),
            const SizedBox(height: 12),
            const _MapPlaceholderCard(),
            if (activity.notes != null && activity.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'הערות',
                        style: t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.notes!,
                        style: t.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutPlanEntryScaffold extends StatelessWidget {
  const _WorkoutPlanEntryScaffold({
    required this.parsed,
  });

  final ({
    int weekIndex,
    int workoutIndex,
    PlanWorkoutEntry entry,
    PlanWeekData week,
  }) parsed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final e = parsed.entry;
    final accent = e.kind.color;
    final status = e.completed ? 'בוצע' : 'מתוכנן';
    final weekLine =
        'שבוע ${parsed.weekIndex} · ${parsed.week.rangeLabelHe()}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('אימון בתכנית'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AccentBar(color: accent),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(status),
                  backgroundColor: e.completed
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                ),
                Chip(label: Text(weekLine)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              e.title,
              style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              e.dayLabel,
              style: t.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'מה בתכנית',
                      style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (e.detail != null && e.detail!.isNotEmpty)
                      Text(e.detail!, style: t.bodyMedium?.copyWith(height: 1.4))
                    else
                      Text(
                        'אין פירוט מרחק/משך בדמו — יוגדר בתכנית אמיתית.',
                        style: t.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                    if (e.completed && e.completedActivityId == null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'סומן כבוצע בתכנית. אין עדיין רשומת פעילות מפורטת (מכשיר/ידני) — '
                        'כשיוקלט אימון, יופיע כאן אותו פירוט כמו במסך פעילות.',
                        style: t.bodySmall?.copyWith(
                          color: Colors.black45,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (!e.completed) ...[
                      const SizedBox(height: 12),
                      Text(
                        'לאחר הביצוע ניתן לסמן ביצוע או לקלוט מהמכשיר — אז יוצג פירוט מלא.',
                        style: t.bodySmall?.copyWith(
                          color: Colors.black45,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _MapPlaceholderCard(),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCalendarSlotScaffold extends StatelessWidget {
  const _WorkoutCalendarSlotScaffold({required this.info});

  final CalendarWorkoutRouteInfo info;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final accent = info.kind.color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('אימון בלוח'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AccentBar(color: accent),
            const SizedBox(height: 16),
            Chip(label: Text('${info.dayLabel} · לוח השבוע')),
            const SizedBox(height: 12),
            Text(
              info.title,
              style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              info.subtitle,
              style: t.bodyLarge?.copyWith(color: Colors.black54, height: 1.35),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'זהו אימון מתוך לוח השבוע הנוכחי. לאחר ביצוע ורישום (או סנכרון מכשיר) '
                  'יוצג כאן פירוט מלא כמו במסך פעילות.',
                  style: t.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _MapPlaceholderCard(),
          ],
        ),
      ),
    );
  }
}

class _AccentBar extends StatelessWidget {
  const _AccentBar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.5),
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholderCard extends StatelessWidget {
  const _MapPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map_outlined, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'מסלול',
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'תצוגת מפה ומסלול GPS — יתווסף כשיחוברו נתוני מכשיר.',
              style: t.bodySmall?.copyWith(
                color: Colors.black45,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF00897B)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
