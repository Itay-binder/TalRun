import 'package:talrun/data/demo_trainee_plan.dart';
import 'package:talrun/theme/workout_colors.dart';
import 'package:talrun/utils/calendar_he.dart';

/// מטא־דאטה לאימון בלוח (מזהה `cal-{יום}-{מספר_ביום}`).
class CalendarWorkoutRouteInfo {
  const CalendarWorkoutRouteInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.dayIndex,
    this.completedActivityId,
  });

  final String id;
  final String title;
  final String subtitle;
  final WorkoutKind kind;
  final int dayIndex;

  /// אם קיים — אותו פירוט כמו מסך פעילות (דמו).
  final String? completedActivityId;

  String get dayLabel => kHebrewWeekdayShort[dayIndex];
}

typedef CalendarWorkoutRoutes = ({
  List<List<CalendarWorkoutRouteInfo>> byDay,
  Map<String, CalendarWorkoutRouteInfo> byId,
});

/// בניית לוח השבוע והמפה לפי מזהה — מקור אחד ללוח ולמסך פירוט.
CalendarWorkoutRoutes buildCalendarWorkoutRoutes() {
  final byDay =
      List<List<CalendarWorkoutRouteInfo>>.generate(7, (_) => []);
  final byId = <String, CalendarWorkoutRouteInfo>{};
  final counters = List<int>.filled(7, 0);

  void add(int day, CalendarWorkoutRouteInfo info) {
    byDay[day].add(info);
    byId[info.id] = info;
  }

  for (var day = 0; day < 7; day++) {
    final slot = demoSlotBySunDay[day];
    if (slot == null) continue;
    final idx = counters[day];
    counters[day]++;
    final id = 'cal-$day-$idx';
    add(
      day,
      CalendarWorkoutRouteInfo(
        id: id,
        title: slot.title,
        subtitle: slot.subtitle,
        kind: slot.kind,
        dayIndex: day,
        completedActivityId: _linkedActivityForSlot(day, idx),
      ),
    );
  }

  // אימון נוסף ביום שני (כמו ב־UI הקיים).
  {
    const day = 1;
    final idx = counters[day];
    counters[day]++;
    add(
      day,
      CalendarWorkoutRouteInfo(
        id: 'cal-$day-$idx',
        title: 'כוח עליון',
        subtitle: '40 דק׳',
        kind: WorkoutKind.strength,
        dayIndex: day,
      ),
    );
  }

  return (byDay: byDay, byId: byId);
}

Map<String, CalendarWorkoutRouteInfo>? _byIdCache;

/// חיפוש לפי מזהה נתיב (למשל `cal-0-0`).
CalendarWorkoutRouteInfo? tryGetCalendarWorkoutRoute(String id) {
  _byIdCache ??= buildCalendarWorkoutRoutes().byId;
  return _byIdCache![id];
}

String? _linkedActivityForSlot(int dayIndex, int slotInDay) {
  if (dayIndex == 0 && slotInDay == 0) return 'a2';
  if (dayIndex == 1 && slotInDay == 0) return 'a1';
  if (dayIndex == 4 && slotInDay == 0) return 'a2';
  return null;
}
