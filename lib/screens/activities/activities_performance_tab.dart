import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talrun/data/activities_demo.dart';

class ActivitiesPerformanceTab extends StatefulWidget {
  const ActivitiesPerformanceTab({super.key});

  @override
  State<ActivitiesPerformanceTab> createState() =>
      _ActivitiesPerformanceTabState();
}

class _ActivitiesPerformanceTabState extends State<ActivitiesPerformanceTab> {
  String _viewBy = 'שבוע';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final summary = demoCurrentWeekSummary();
    final weekly = demoWeeklyKmSeries();
    final trend = demoPaceTrend();
    final prs = demoPersonalRecords();
    final races = demoRaceResults();

    final maxKm = weekly.map((e) => e.km).reduce(math.max) * 1.15;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                summary.rangeLabel,
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            PopupMenuButton<String>(
              initialValue: _viewBy,
              onSelected: (v) => setState(() => _viewBy = v),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'שבוע', child: Text('תצוגה: שבוע')),
                const PopupMenuItem(value: 'חודש', child: Text('תצוגה: חודש')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'תצוגה: $_viewBy',
                      style: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'קילומטרים',
                value: summary.km.toStringAsFixed(2),
              ),
            ),
            Expanded(
              child: _SummaryTile(
                label: 'זמן',
                value: formatDurationHe(summary.time),
              ),
            ),
            Expanded(
              child: _SummaryTile(
                label: 'פעילויות',
                value: '${summary.activityCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'קילומטראז׳ שבועי',
          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'סה״כ ק״מ לכל שבוע מאז תחילת האימונים (דמו).',
          style: t.bodySmall?.copyWith(color: Colors.black45, height: 1.3),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxKm,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= weekly.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              weekly[i].weekStartLabel,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: maxKm > 25 ? 10 : 5,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxKm > 25 ? 10 : 5,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(weekly.length, (i) {
                    final w = weekly[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: w.km,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          color: w.highlight
                              ? const Color(0xFF26A69A)
                              : Colors.grey.shade400,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'מגמת שיפור — קצב 5K (דקות, נמוך יותר = טוב יותר)',
          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (trend.length - 1).toDouble(),
                  minY: 4.6,
                  maxY: 5.15,
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= trend.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            trend[i].monthLabel,
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 0.1,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        trend.length,
                        (i) => FlSpot(i.toDouble(), trend[i].pace5kMinutes),
                      ),
                      isCurved: true,
                      color: const Color(0xFF00897B),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF00897B).withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'שיאים אישיים',
          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.72,
              ),
              itemCount: prs.length,
              itemBuilder: (context, i) => _PrBadge(record: prs[i]),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'מירוצים והישגים רשמיים',
          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ...races.map(
          (r) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(r.name, style: t.titleSmall),
              subtitle: Text(
                '${DateFormat.yMMMd('he_IL').format(r.date)} · ${r.distanceLabel}\n${r.category}',
                style: t.bodySmall?.copyWith(height: 1.3),
              ),
              isThreeLine: true,
              trailing: Text(
                r.officialTime,
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00695C),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'סטטיסטיקות כוללות',
          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const _AllTimeStatsCard(),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

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
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _PrBadge extends StatelessWidget {
  const _PrBadge({required this.record});

  final DemoPersonalRecord record;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = record.borderColor ?? Colors.grey;
    final dateStr = record.date != null
        ? DateFormat.yMMMd('he_IL').format(record.date!)
        : '';

    return Column(
      children: [
        CustomPaint(
          size: const Size(48, 48),
          painter: _HexPainter(
            color: record.unlocked ? c : Colors.grey.shade400,
            fill: record.unlocked,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          record.label,
          style: t.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        Text(
          record.timeLabel,
          style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        if (dateStr.isNotEmpty)
          Text(
            dateStr,
            style: t.labelSmall?.copyWith(color: Colors.black45),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _HexPainter extends CustomPainter {
  _HexPainter({required this.color, required this.fill});

  final Color color;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 2;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) - math.pi / 6;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    if (fill) {
      final pFill = Paint()..color = color.withValues(alpha: 0.18);
      canvas.drawPath(path, pFill);
    }
    final pStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, pStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AllTimeStatsCard extends StatelessWidget {
  const _AllTimeStatsCard();

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.route, 'סה״כ מרחק', '372 ק״מ'),
      (Icons.directions_run, 'סה״כ פעילויות', '50'),
      (Icons.timer_outlined, 'סה״כ זמן', '40שע 51דק'),
      (Icons.sports_martial_arts, 'הריצה הארוכה ביותר', '21.1 ק״מ'),
      (Icons.assignment_turned_in, 'אימוני ריצה בתכנית', '34'),
      (Icons.fitness_center, 'אימוני כוח בתכנית', '5'),
      (Icons.self_improvement, 'יוגה בתכנית', '0'),
      (Icons.accessibility_new, 'פילאטיס בתכנית', '0'),
      (Icons.airline_seat_recline_normal, 'מתיחות ויציבות בתכנית', '0'),
    ];

    return Card(
      elevation: 1,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              leading: Icon(rows[i].$1, color: const Color(0xFF00897B)),
              title: Text(
                rows[i].$2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black45,
                    ),
              ),
              trailing: Text(
                rows[i].$3,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
