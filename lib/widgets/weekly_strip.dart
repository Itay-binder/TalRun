import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:talrun/theme/workout_colors.dart';

/// שורת 7 ימים עם נקודות צבע לפי סוג אימון (mock).
class WeeklyStrip extends StatelessWidget {
  const WeeklyStrip({
    super.key,
    required this.labels,
    required this.dayNumbers,
    required this.selectedIndex,
    required this.markersByDayIndex,
  });

  final List<String> labels;
  final List<int> dayNumbers;
  final int selectedIndex;
  /// לכל יום — רשימת סוגי אימון להצגה כריבועים קטנים.
  final List<List<WorkoutKind>> markersByDayIndex;

  @override
  Widget build(BuildContext context) {
    // RTL באפליקציה הופך Row — בלי LTR יום א׳ היה מימין. כאן: א׳ משמאל, ש׳ מימין.
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.black : Colors.black45,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${dayNumbers[i]}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _DayMarkers(kinds: markersByDayIndex[i]),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DayMarkers extends StatelessWidget {
  const _DayMarkers({required this.kinds});

  final List<WorkoutKind> kinds;

  @override
  Widget build(BuildContext context) {
    if (kinds.isEmpty) return const SizedBox(height: 8);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2,
      runSpacing: 2,
      children: kinds
          .map(
            (k) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: k.color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          )
          .toList(),
    );
  }
}
