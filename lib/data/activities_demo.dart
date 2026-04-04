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
    this.notes,
    this.avgHeartRate,
    this.calories,
    this.elevationGainM,
  });

  final String id;
  final DateTime start;
  final String title;
  final double distanceKm;
  final Duration duration;
  final int avgPaceSecPerKm;
  final Color accent;
  final String source;

  /// טקסט חופשי לפירוט מסך האימון.
  final String? notes;

  /// דופק ממוצע (אופציונלי).
  final int? avgHeartRate;

  /// קלוריות משוערות.
  final int? calories;

  /// עלייה מצטברת במטרים (ריצה).
  final int? elevationGainM;

  bool get hasDistance => distanceKm > 0;
}

/// חיפוש פעילות לפי מזהה (דמו / עתיד: Firestore).
DemoActivity? demoActivityById(String id) {
  for (final a in demoActivitiesList()) {
    if (a.id == id) return a;
  }
  return null;
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

/// נקודה בגרף שיפור — קצב ממוצע בדקות לק״מ (נמוך = טוב יותר).
class DemoPaceTrendPoint {
  const DemoPaceTrendPoint(this.periodLabel, this.avgPaceMinPerKm);

  final String periodLabel;
  final double avgPaceMinPerKm;
}

/// מרחק לבחירה במגמת שיפור (דמו).
enum DemoTrendDistance {
  km5(5.0, '5 ק״מ'),
  km10(10.0, '10 ק״מ'),
  km15(15.0, '15 ק״מ'),
  kmHalf(21.1, 'חצי מרתון');

  const DemoTrendDistance(this.kmValue, this.labelHe);

  final double kmValue;
  final String labelHe;
}

/// עמודת נפח (שבוע או חודש) — ק״מ מצטבר.
class DemoVolumeBar {
  const DemoVolumeBar(this.label, this.km, {this.highlight = false});

  final String label;
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
      notes:
          'בלוק ארוך בקצב יציב. 2 ק״מ חימום, 5 ק״מ בקצב מטרה, 200 מ׳ ריצה קלה. '
          'מרגיש טוב — לשמור על אותו קצב בשבוע הבא.',
      avgHeartRate: 148,
      calories: 520,
      elevationGainM: 42,
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
      notes: 'ריצת בוקר קלה. ללא כאבים.',
      avgHeartRate: 132,
      calories: 310,
      elevationGainM: 18,
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
      notes:
          'סקוואט, דלגים, כפיפות בטן, ישבן. 3 סטים לתרגיל — משקל בינוני.',
      calories: 180,
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

/// מגמת קצב לפי מרחק (דמו — חודשים זהים, ערכי קצב שונים).
List<DemoPaceTrendPoint> demoPaceTrendFor(DemoTrendDistance d) {
  return switch (d) {
    DemoTrendDistance.km5 => const [
        DemoPaceTrendPoint('ינו׳', 5.05),
        DemoPaceTrendPoint('פבר׳', 4.95),
        DemoPaceTrendPoint('מרץ', 4.88),
        DemoPaceTrendPoint('אפר׳', 4.82),
      ],
    DemoTrendDistance.km10 => const [
        DemoPaceTrendPoint('ינו׳', 5.38),
        DemoPaceTrendPoint('פבר׳', 5.24),
        DemoPaceTrendPoint('מרץ', 5.14),
        DemoPaceTrendPoint('אפר׳', 5.06),
      ],
    DemoTrendDistance.km15 => const [
        DemoPaceTrendPoint('ינו׳', 5.58),
        DemoPaceTrendPoint('פבר׳', 5.48),
        DemoPaceTrendPoint('מרץ', 5.38),
        DemoPaceTrendPoint('אפר׳', 5.30),
      ],
    DemoTrendDistance.kmHalf => const [
        DemoPaceTrendPoint('ינו׳', 5.82),
        DemoPaceTrendPoint('פבר׳', 5.72),
        DemoPaceTrendPoint('מרץ', 5.62),
        DemoPaceTrendPoint('אפר׳', 5.52),
      ],
  };
}

/// קילומטראז׳ שבועי (כל עמודה = שבוע).
List<DemoVolumeBar> demoWeeklyVolumeSeries() {
  return const [
    DemoVolumeBar('16 בפבר׳', 18),
    DemoVolumeBar('23 בפבר׳', 22),
    DemoVolumeBar('2 במרץ', 25),
    DemoVolumeBar('9 במרץ', 20),
    DemoVolumeBar('16 במרץ', 28),
    DemoVolumeBar('23 במרץ', 24),
    DemoVolumeBar('30 במרץ', 16.68, highlight: true),
  ];
}

/// קילומטראז׳ חודשי (כל עמודה = חודש שלם).
List<DemoVolumeBar> demoMonthlyVolumeSeries() {
  return const [
    DemoVolumeBar('נוב׳ 25', 72),
    DemoVolumeBar('דצמ׳ 25', 88),
    DemoVolumeBar('ינו׳ 26', 95),
    DemoVolumeBar('פבר׳ 26', 102),
    DemoVolumeBar('מרץ 26', 118),
    DemoVolumeBar('אפר׳ 26', 42, highlight: true),
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

/// סיכום חודש נוכחי (דמו) — כשהתצוגה היא לפי חודש.
DemoWeekPerformanceSummary demoCurrentMonthSummary() {
  return DemoWeekPerformanceSummary(
    rangeLabel: 'אפריל 2026',
    km: 42,
    time: const Duration(hours: 5, minutes: 12, seconds: 10),
    activityCount: 9,
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
