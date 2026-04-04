import 'package:talrun/theme/workout_colors.dart';
import 'package:talrun/utils/calendar_he.dart';

/// דמו: שבוע אחד חוזר. אינדקס לפי [weekdayIndexFromSunday].
const demoWeekCurrent = 3;
const demoWeekTotal = 12;

final List<List<WorkoutKind>> demoMarkersBySunDay = [
  [WorkoutKind.run],
  [WorkoutKind.run, WorkoutKind.strength],
  [],
  [],
  [WorkoutKind.run],
  [WorkoutKind.mobility],
  [WorkoutKind.stretch],
];

class TraineeDaySlot {
  const TraineeDaySlot({
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String title;
  final String subtitle;
  final WorkoutKind kind;
}

/// null = יום מנוחה
final List<TraineeDaySlot?> demoSlotBySunDay = [
  TraineeDaySlot(
    title: 'ריצה קלה',
    subtitle: '5 ק״מ • 35 דק׳',
    kind: WorkoutKind.run,
  ),
  TraineeDaySlot(
    title: 'חזרות גבעה',
    subtitle: '7.5 ק״מ • 50 דק׳',
    kind: WorkoutKind.run,
  ),
  null,
  null,
  TraineeDaySlot(
    title: 'ריצת ביניים',
    subtitle: '6 ק״מ • 40 דק׳',
    kind: WorkoutKind.run,
  ),
  TraineeDaySlot(
    title: 'מוביליטי',
    subtitle: '25 דק׳',
    kind: WorkoutKind.mobility,
  ),
  null,
];

TraineeDaySlot? todaySlotFor(DateTime now) {
  final i = weekdayIndexFromSunday(now);
  return demoSlotBySunDay[i];
}

List<List<WorkoutKind>> markersForTrainee(bool hasPlan) {
  if (!hasPlan) {
    return List.generate(7, (_) => <WorkoutKind>[]);
  }
  return demoMarkersBySunDay;
}
