import 'package:flutter/material.dart';

/// תחזית קצבים לפי מרחק + סיכום ביצועים (דמו).
class PaceInsightsScreen extends StatelessWidget {
  const PaceInsightsScreen({super.key});

  static const _rows = [
    _PaceRow('5 ק״מ', '4:45', '4:32', 'יציב — שיפור קטן בשלושת החודשים האחרונים'),
    _PaceRow('10 ק״מ', '5:05', '4:58', 'קצב ארוך טוב יחסית ל־5K'),
    _PaceRow('חצי מרתון', '5:25', '5:18', 'התמדה באימוני ביניים תומכת במגמה'),
    _PaceRow('מרתון', '5:50', '—', 'תחזית ראשונית לפי נפח וקצב נוכחי'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('תובנות קצב')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'תחזית קצב לפי מרחק',
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'הערכות לפי נתוני האימונים שלך (דמו). בעתיד: מודל אישי לפי היסטוריה.',
            style: t.bodyMedium?.copyWith(color: Colors.black54, height: 1.35),
          ),
          const SizedBox(height: 20),
          ..._rows.map((r) => _PaceCard(row: r)),
          const SizedBox(height: 24),
          Text(
            'ביצועים אחרונים',
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ב־30 הימים האחרונים השלמת 18 אימוני ריצה, ממוצע שבועי כ־32 ק״מ.',
                    style: t.bodyMedium?.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'קצב אימון ביניים משתפר; מומלץ לשמור על אימון איכות אחד בשבוע.',
                    style: t.bodyMedium?.copyWith(
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaceRow {
  const _PaceRow(this.distance, this.current, this.predicted, this.note);

  final String distance;
  final String current;
  final String predicted;
  final String note;
}

class _PaceCard extends StatelessWidget {
  const _PaceCard({required this.row});

  final _PaceRow row;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              row.distance,
              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'קצב נוכחי (דק׳/ק״מ)',
                    value: row.current,
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'תחזית',
                    value: row.predicted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              row.note,
              style: t.bodySmall?.copyWith(color: Colors.black54, height: 1.3),
            ),
          ],
        ),
      ),
    );
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
          label,
          style: t.labelSmall?.copyWith(color: Colors.black45),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
