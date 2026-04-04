import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:talrun/data/demo_trainee_plan.dart';
import 'package:talrun/state/app_state.dart';
import 'package:talrun/state/user_role.dart';
import 'package:talrun/theme/workout_colors.dart';
import 'package:talrun/utils/calendar_he.dart';

/// מסך לוח האימונים בכיוון LTR (ימי השבוע משמאל לימין), בלי לשנות את שאר האפליקציה.
Widget _wrapTrainingCalendarLtr(Widget child) {
  return Directionality(
    textDirection: ui.TextDirection.ltr,
    child: child,
  );
}

class TrainingCalendarScreen extends StatelessWidget {
  const TrainingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    if (app.role == UserRole.coach) {
      return _wrapTrainingCalendarLtr(
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('לוח אימונים'),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'ממשק מאמן: כאן יוצג לוח לפי מתאמן נבחר.\n'
                'בשלב זה אין עדיין רשימת מתאמנים — נחבר ל-Firestore בהמשך.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.4),
              ),
            ),
          ),
        ),
      );
    }

    if (!app.hasActivePlan) {
      return _wrapTrainingCalendarLtr(
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('לוח אימונים'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'אין תכנית פעילה',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'כשתהיה לך תכנית, השבועות והאימונים יופיעו כאן.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54, height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return const _TraineeDragCalendar();
  }
}

/// לוח שבועי עם גרירה בין ימים; שמירה = עדכון state מקומי (מוכן ל-Firestore).
class _TraineeDragCalendar extends StatefulWidget {
  const _TraineeDragCalendar();

  @override
  State<_TraineeDragCalendar> createState() => _TraineeDragCalendarState();
}

class _TraineeDragCalendarState extends State<_TraineeDragCalendar> {
  late List<List<_CalendarWorkoutItem>> _byDay;
  late List<List<_CalendarWorkoutItem>> _initialSnapshot;

  @override
  void initState() {
    super.initState();
    final initial = _buildInitialWeek();
    _initialSnapshot =
        List.generate(7, (i) => List<_CalendarWorkoutItem>.from(initial[i]));
    _byDay = List.generate(7, (i) => List<_CalendarWorkoutItem>.from(initial[i]));
  }

  /// מילוי התחלתי מהדמו + אימון נוסף ביום שני (כמו במקורות UI).
  List<List<_CalendarWorkoutItem>> _buildInitialWeek() {
    final lists = List<List<_CalendarWorkoutItem>>.generate(7, (_) => []);
    var n = 0;
    for (var i = 0; i < 7; i++) {
      final slot = demoSlotBySunDay[i];
      if (slot != null) {
        lists[i].add(
          _CalendarWorkoutItem(
            id: 'w$n',
            title: slot.title,
            subtitle: slot.subtitle,
            kind: slot.kind,
          ),
        );
        n++;
      }
    }
    lists[1].add(
      _CalendarWorkoutItem(
        id: 'w$n',
        title: 'כוח עליון',
        subtitle: '40 דק׳',
        kind: WorkoutKind.strength,
      ),
    );
    return lists;
  }

  void _resetWeek() {
    setState(() {
      _byDay = List.generate(
        7,
        (i) => List<_CalendarWorkoutItem>.from(_initialSnapshot[i]),
      );
    });
  }

  void _moveToDay(_CalendarWorkoutItem item, int targetDayIndex) {
    setState(() {
      for (final list in _byDay) {
        list.removeWhere((e) => e.id == item.id);
      }
      _byDay[targetDayIndex].add(item);
    });
    // כאן בעתיד: שמירה ל-Firestore / שרת
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = startOfWeekSunday(now);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final rangeLabel =
        '${DateFormat.MMMd('he_IL').format(weekStart)} – ${DateFormat.MMMd('he_IL').format(weekEnd)}';

    return _wrapTrainingCalendarLtr(
      Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('לוח אימונים'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WeekHeader(
              rangeLabel: rangeLabel,
              weekLabel: 'שבוע $demoWeekCurrent',
              totalDone: '16.7 ק״מ',
              totalGoal: '19.5 ק״מ',
              onReset: _resetWeek,
            ),
            const SizedBox(height: 8),
            Text(
              'לחיצה ארוכה על כרטיס אימון ואז גרירה ליום אחר. השינוי נשמר מיד במסך '
              '(בהמשך: סנכרון לענן).',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < 7; i++)
              _DayDropRow(
                dayLabel: kHebrewWeekdayShort[i],
                dayNum: weekStart.add(Duration(days: i)).day,
                highlight: startOfLocalDay(weekStart.add(Duration(days: i))) ==
                    startOfLocalDay(now),
                items: _byDay[i],
                onAccept: (item) => _moveToDay(item, i),
                onCardTap: (item) =>
                    context.push('/workout/${item.title.hashCode}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarWorkoutItem {
  const _CalendarWorkoutItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String id;
  final String title;
  final String subtitle;
  final WorkoutKind kind;
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.rangeLabel,
    required this.weekLabel,
    required this.totalDone,
    required this.totalGoal,
    required this.onReset,
  });

  final String rangeLabel;
  final String weekLabel;
  final String totalDone;
  final String totalGoal;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          rangeLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          weekLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'סה״כ: $totalDone / $totalGoal',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('איפוס'),
            ),
          ],
        ),
      ],
    );
  }
}

class _DayDropRow extends StatelessWidget {
  const _DayDropRow({
    required this.dayLabel,
    required this.dayNum,
    required this.highlight,
    required this.items,
    required this.onAccept,
    required this.onCardTap,
  });

  final String dayLabel;
  final int dayNum;
  final bool highlight;
  final List<_CalendarWorkoutItem> items;
  final void Function(_CalendarWorkoutItem item) onAccept;
  final void Function(_CalendarWorkoutItem item) onCardTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  dayLabel,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: highlight ? Colors.black : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$dayNum',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: highlight ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<_CalendarWorkoutItem>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) => onAccept(details.data),
              builder: (context, candidate, rejected) {
                final hovering = candidate.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hovering
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                    color: hovering
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.06)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            hovering
                                ? 'שחרר כאן'
                                : 'יום מנוחה — גרור לכאן אימון',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _DraggableWorkoutCard(
                              item: item,
                              onTap: () => onCardTap(item),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DraggableWorkoutCard extends StatelessWidget {
  const _DraggableWorkoutCard({
    required this.item,
    required this.onTap,
  });

  final _CalendarWorkoutItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = _WorkoutCardShell(
      title: item.title,
      subtitle: item.subtitle,
      kind: item.kind,
      onTap: onTap,
    );

    return LongPressDraggable<_CalendarWorkoutItem>(
      data: item,
      hapticFeedbackOnStart: true,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: 0.95,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.72,
            child: _WorkoutCardShell(
              title: item.title,
              subtitle: item.subtitle,
              kind: item.kind,
              onTap: () {},
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }
}

class _WorkoutCardShell extends StatelessWidget {
  const _WorkoutCardShell({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final WorkoutKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: kind.color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.drag_indicator,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
