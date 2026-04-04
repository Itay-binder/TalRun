import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:talrun/data/activities_demo.dart';

/// פירוט אימון / פעילות שבוצעה (דמו לפי מזהה; בעתיד Firestore).
class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context) {
    final activity = demoActivityById(workoutId);
    final t = Theme.of(context).textTheme;

    if (activity == null) {
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
            Container(
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    activity.accent,
                    activity.accent.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
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
            Card(
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
                          style: t.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
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
            ),
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
