import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:talrun/data/activities_demo.dart';

class ActivitiesWorkoutsTab extends StatelessWidget {
  const ActivitiesWorkoutsTab({super.key, required this.hasActivePlan});

  /// בלי תכנית פעילה לא מציגים דמו — רק הודעה (פעילות ידנית עדיין זמינה מ־+).
  final bool hasActivePlan;

  @override
  Widget build(BuildContext context) {
    if (!hasActivePlan) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'אין תכנית פעילה',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'כשתתחילו תכנית — אימונים ופעילויות שמקושרות אליה יוצגו כאן. '
                'בינתיים אפשר להוסיף פעילות ידנית בכפתור + למעלה.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.push('/plan'),
                child: const Text('מעבר למסך התכנית'),
              ),
            ],
          ),
        ),
      );
    }

    final activities = demoActivitiesList();
    final grouped = _groupByMonth(activities);

    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'עדיין אין פעילויות. הוסיפו ידנית או חברו מכשיר.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: grouped.length,
      itemBuilder: (context, gi) {
        final entry = grouped[gi];
        final monthLabel = entry.key;
        final list = entry.value;
        final monthKm = list.fold<double>(0, (s, a) => s + a.distanceKm);
        final monthDur = list.fold<Duration>(
          Duration.zero,
          (s, a) => s + a.duration,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8, top: gi > 0 ? 16 : 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthLabel,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${list.length} פעילויות · ${formatDurationHe(monthDur)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black45,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${monthKm.toStringAsFixed(1)} ק״מ',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            ...list.map((a) => _ActivityCard(activity: a)),
          ],
        );
      },
    );
  }
}

List<MapEntry<String, List<DemoActivity>>> _groupByMonth(
  List<DemoActivity> all,
) {
  final map = <String, List<DemoActivity>>{};
  for (final a in all) {
    final key = DateFormat.yMMMM('he_IL').format(a.start);
    map.putIfAbsent(key, () => []).add(a);
  }
  final keys = map.keys.toList()
    ..sort((a, b) => map[b]!.first.start.compareTo(map[a]!.first.start));
  return keys.map((k) => MapEntry(k, map[k]!)).toList();
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final DemoActivity activity;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final dateStr =
        '${DateFormat.MMMd('he_IL').format(activity.start)} · ${DateFormat.Hm('he_IL').format(activity.start)}';
    final hasDistance = activity.distanceKm > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: () => context.push('/workout/${activity.id}'),
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(14),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        activity.accent,
                        activity.accent.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.timeline,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateStr,
                                    style: t.bodySmall?.copyWith(
                                      color: Colors.black45,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activity.title,
                                    style: t.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: 'מרחק',
                                value: hasDistance
                                    ? '${activity.distanceKm.toStringAsFixed(2)} ק״מ'
                                    : '—',
                              ),
                            ),
                            Expanded(
                              child: _MiniStat(
                                label: 'זמן',
                                value: _formatClock(activity.duration),
                              ),
                            ),
                            Expanded(
                              child: _MiniStat(
                                label: 'קצב ממוצע',
                                value: hasDistance
                                    ? formatPaceHe(activity.avgPaceSecPerKm)
                                    : '—',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'RF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'איך הרגשתם באימון? דירוג יפתח תובנות.',
                                style: t.labelSmall?.copyWith(
                                  color: Colors.black45,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_down_alt_outlined),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('תודה על המשוב')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_up_alt_outlined),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('תודה על המשוב')),
                                );
                              },
                            ),
                          ],
                        ),
                        Text(
                          'מקור: ${activity.source}',
                          style: t.labelSmall?.copyWith(color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatClock(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: t.labelSmall?.copyWith(
            color: Colors.black38,
            fontSize: 10,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: t.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
