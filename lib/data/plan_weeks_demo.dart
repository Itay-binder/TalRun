import 'package:intl/intl.dart';
import 'package:talrun/data/demo_trainee_plan.dart';
import 'package:talrun/theme/workout_colors.dart';

/// יום ראשון של שבוע 1 בתכנית הדמו.
final DateTime kPlanWeek1Sunday = DateTime(2025, 3, 16);

DateTime planWeekStartSunday(int weekIndex1Based) =>
    kPlanWeek1Sunday.add(Duration(days: 7 * (weekIndex1Based - 1)));

class PlanWorkoutEntry {
  const PlanWorkoutEntry({
    required this.dayLabel,
    required this.title,
    required this.completed,
    required this.kind,
    this.detail,
  });

  final String dayLabel;
  final String title;
  final bool completed;
  final WorkoutKind kind;
  final String? detail;
}

class PlanWeekData {
  const PlanWeekData({
    required this.weekIndex,
    required this.workouts,
  });

  final int weekIndex;
  final List<PlanWorkoutEntry> workouts;

  bool get isCompleted => weekIndex < demoWeekCurrent;
  bool get isCurrent => weekIndex == demoWeekCurrent;
  bool get isLocked => weekIndex > demoWeekCurrent;

  int get workoutsDone => workouts.where((e) => e.completed).length;
  int get workoutsTotal => workouts.length;

  double get kmDone => _kmDoneForWeek(weekIndex);
  double get kmGoal => _kmGoalForWeek(weekIndex);

  String rangeLabelHe() {
    final s = planWeekStartSunday(weekIndex);
    final e = s.add(const Duration(days: 6));
    return '${DateFormat.MMMd('he_IL').format(s)} – ${DateFormat.MMMd('he_IL').format(e)}';
  }
}

const kPlanTitleHe = 'תכנית ריצה מהירה';
const kPlanWeeksCompletedDisplay = 2;
const kPlanDistanceDoneKm = 37.0;
const kPlanDistanceGoalKm = 244.9;

List<PlanWeekData> buildDemoPlanWeeks() {
  return List.generate(
    demoWeekTotal,
    (i) => PlanWeekData(weekIndex: i + 1, workouts: _workoutsForWeek(i + 1)),
  );
}

double _kmDoneForWeek(int w) {
  return switch (w) {
    1 => 5.5,
    2 => 18.5,
    3 => 14.7,
    _ => 0.0,
  };
}

double _kmGoalForWeek(int w) {
  return switch (w) {
    1 => 11.5,
    2 => 18.5,
    3 => 19.5,
    _ => 20.0,
  };
}

List<PlanWorkoutEntry> _workoutsForWeek(int w) {
  return switch (w) {
    1 => [
        const PlanWorkoutEntry(
          dayLabel: 'יום ב׳',
          title: 'ריצה קלה',
          completed: true,
          kind: WorkoutKind.run,
          detail: '5 ק״מ',
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום ג׳',
          title: 'רגליים וליבה',
          completed: true,
          kind: WorkoutKind.strength,
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום ו׳',
          title: 'ריצה ארוכה',
          completed: false,
          kind: WorkoutKind.run,
          detail: '11.5 ק״מ',
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום א׳',
          title: 'גוף מלא',
          completed: true,
          kind: WorkoutKind.strength,
        ),
      ],
    2 => [
        const PlanWorkoutEntry(
          dayLabel: 'יום ב׳',
          title: 'אינטרוולים',
          completed: true,
          kind: WorkoutKind.run,
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום ד׳',
          title: 'ריצה קלה',
          completed: true,
          kind: WorkoutKind.run,
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום ו׳',
          title: 'טמפו',
          completed: true,
          kind: WorkoutKind.run,
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום א׳',
          title: 'מוביליטי',
          completed: true,
          kind: WorkoutKind.mobility,
        ),
      ],
    3 => [
        const PlanWorkoutEntry(
          dayLabel: 'יום ב׳',
          title: 'גבעות',
          completed: true,
          kind: WorkoutKind.run,
          detail: '6 ק״מ',
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום ד׳',
          title: 'ריצה קלה',
          completed: true,
          kind: WorkoutKind.run,
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום ו׳',
          title: 'ריצה ארוכה',
          completed: false,
          kind: WorkoutKind.run,
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום א׳',
          title: 'מתיחות',
          completed: false,
          kind: WorkoutKind.stretch,
        ),
      ],
    _ => [
        const PlanWorkoutEntry(
          dayLabel: 'יום ב׳',
          title: 'אימון ריצה',
          completed: false,
          kind: WorkoutKind.run,
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום ה׳',
          title: 'כוח',
          completed: false,
          kind: WorkoutKind.strength,
        ),
        const PlanWorkoutEntry(
          dayLabel: 'יום ו׳',
          title: 'ריצה ארוכה',
          completed: false,
          kind: WorkoutKind.run,
        ),
      ],
  };
}
