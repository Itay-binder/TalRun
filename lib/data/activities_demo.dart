import 'package:flutter/material.dart';

/// פעילות בודדת (דמו — בעתיד ממקור נתונים / סנכרון).
class DemoActivity {
  const DemoActivity({
    required this.id,
    required this.start,
    required this.title,
    required this.distanceKm,
    required this.duration,
    required this.avgPaceSecPerKm,
    required this.accent,
    required this.source,
  });

  final String id;
  final DateTime start;
  final String title;
  final double distanceKm;
  final Duration duration;
  final int avgPaceSecPerKm;
  final Color accent;
  final String source;
}

/// שיא אישי (דמו).
class DemoPersonalRecord {
  const DemoPersonalRecord({
    required this.label,
    required this.timeLabel,
    required this.date,
    required this.unlocked,
    this.borderColor,
  });

  final String label;
  final String timeLabel;
  final DateTime? date;
  final bool unlocked;
  final Color? borderColor;
}

/// מירוץ עם תוצאה רשמית.
class DemoRaceResult {
  const DemoRaceResult({
    required this.name,
    required this.date,
    required this.distanceLabel,
    required this.officialTime,
    required this.category,
  });

  final String name;
  final DateTime date;
  final String distanceLabel;
  final String officialTime;
  final String category;
}

/// נקודה בגרף שיפור (קצב ממוצע ל־5K בדקות).
class DemoPaceTrendPoint {
  const DemoPaceTrendPoint(this.monthLabel, this.pace5kMinutes);

  final String monthLabel;
  final double pace5kMinutes;
}

/// שבוע + קילומטראז׳.
class DemoWeeklyKm {
  const DemoWeeklyKm(this.weekStartLabel, this.km, {this.highlight = false});

  final String weekStartLabel;
  final double km;
  final bool highlight;
}

List<DemoActivity> demoActivitiesList() {
  return [
    DemoActivity(
      id: 'a1',
      start: DateTime(2026, 4, 2, 17, 22),
      title: 'ריצת בלוק ארוכה 7 ק״מ',
      distanceKm: 7.15,
      duration: const Duration(minutes: 46, seconds: 15),
      avgPaceSecPerKm: 6 * 60 + 28,
      accent: const Color(0xFF7E57C2),
      source: 'Garmin Forerunner 235',
    ),
    DemoActivity(
      id: 'a2',
      start: DateTime(2026, 3, 28, 7, 5),
      title: 'ריצה קלה',
      distanceKm: 5.02,
      duration: const Duration(minutes: 32, seconds: 40),
      avgPaceSecPerKm: 6 * 60 + 30,
      accent: const Color(0xFF2E7D32),
      source: 'Strava',
    ),
    DemoActivity(
      id: 'a3',
      start: DateTime(2026, 3, 15, 9, 0),
      title: 'אימון כוח — רגליים',
      distanceKm: 0,
      duration: const Duration(minutes: 45),
      avgPaceSecPerKm: 0,
      accent: const Color(0xFF0288D1),
      source: 'הזנה ידנית',
    ),
  ];
}

List<DemoPersonalRecord> demoPersonalRecords() {
  return [
    const DemoPersonalRecord(
      label: '1K',
      timeLabel: '3:36',
      date: null,
      unlocked: true,
      borderColor: Color(0xFF9E9E9E),
    ),
    const DemoPersonalRecord(
      label: '5K',
      timeLabel: '22:10',
      date: null,
      unlocked: true,
      borderColor: Color(0xFF5C6BC0),
    ),
    const DemoPersonalRecord(
      label: '10K',
      timeLabel: '46:02',
      date: null,
      unlocked: true,
      borderColor: Color(0xFF26A69A),
    ),
    DemoPersonalRecord(
      label: 'חצי מרתון',
      timeLabel: '1:42:18',
      date: DateTime(2025, 11, 7),
      unlocked: true,
      borderColor: Colors.amber.shade700,
    ),
    DemoPersonalRecord(
      label: 'מרתון',
      timeLabel: '3:38:05',
      date: DateTime(2026, 2, 27),
      unlocked: true,
      borderColor: const Color(0xFF1565C0),
    ),
    const DemoPersonalRecord(
      label: '50K',
      timeLabel: '—',
      date: null,
      unlocked: false,
    ),
    const DemoPersonalRecord(
      label: '100K',
      timeLabel: '—',
      date: null,
      unlocked: false,
    ),
  ];
}

List<DemoRaceResult> demoRaceResults() {
  return [
    DemoRaceResult(
      name: 'מרתון תל אביב',
      date: DateTime(2026, 2, 27),
      distanceLabel: '42.2 ק״מ',
      officialTime: '3:38:05',
      category: 'גברים 40–44',
    ),
    DemoRaceResult(
      name: 'חצי ירושלים',
      date: DateTime(2025, 11, 7),
      distanceLabel: '21.1 ק״מ',
      officialTime: '1:42:18',
      category: 'כללי',
    ),
    DemoRaceResult(
      name: '10K רמת גן',
      date: DateTime(2025, 8, 3),
      distanceLabel: '10 ק״מ',
      officialTime: '46:02',
      category: 'שעת בוקר',
    ),
  ];
}

List<DemoPaceTrendPoint> demoPaceTrend() {
  return const [
    DemoPaceTrendPoint('ינו׳', 5.05),
    DemoPaceTrendPoint('פבר׳', 4.95),
    DemoPaceTrendPoint('מרץ', 4.88),
    DemoPaceTrendPoint('אפר׳', 4.82),
  ];
}

List<DemoWeeklyKm> demoWeeklyKmSeries() {
  return [
    const DemoWeeklyKm('16 בפבר׳', 18),
    const DemoWeeklyKm('23 בפבר׳', 22),
    const DemoWeeklyKm('2 במרץ', 25),
    const DemoWeeklyKm('9 במרץ', 20),
    const DemoWeeklyKm('16 במרץ', 28),
    const DemoWeeklyKm('23 במרץ', 24),
    const DemoWeeklyKm('30 במרץ', 16.68, highlight: true),
  ];
}

/// סיכום שבוע נוכחי (דמו) לכרטיס ביצועים.
class DemoWeekPerformanceSummary {
  const DemoWeekPerformanceSummary({
    required this.rangeLabel,
    required this.km,
    required this.time,
    required this.activityCount,
  });

  final String rangeLabel;
  final double km;
  final Duration time;
  final int activityCount;
}

DemoWeekPerformanceSummary demoCurrentWeekSummary() {
  return DemoWeekPerformanceSummary(
    rangeLabel: '30 במרץ – 6 באפר׳',
    km: 16.68,
    time: const Duration(hours: 1, minutes: 50, seconds: 46),
    activityCount: 3,
  );
}

String formatDurationHe(Duration d) {
  if (d.inHours > 0) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${d.inHours}שע $mדק${s > 0 ? ' $sשנ׳' : ''}';
  }
  if (d.inMinutes > 0) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '$mדק${s > 0 ? ' $sשנ׳' : ''}';
  }
  return '${d.inSeconds}שנ׳';
}

String formatPaceHe(int secPerKm) {
  if (secPerKm <= 0) return '—';
  final m = secPerKm ~/ 60;
  final s = secPerKm % 60;
  return '$m:${s.toString().padLeft(2, '0')} דק׳/ק״מ';
}
