import 'package:flutter/material.dart';

/// צבעי סוגי אימון (MVP — mock).
enum WorkoutKind {
  run,
  strength,
  mobility,
  accessory,
  stretch,
}

extension WorkoutKindColors on WorkoutKind {
  Color get color => switch (this) {
        WorkoutKind.run => const Color(0xFF2E7D32),
        WorkoutKind.strength => const Color(0xFF7E57C2),
        WorkoutKind.mobility => const Color(0xFF42A5F5),
        WorkoutKind.accessory => const Color(0xFFE53935),
        WorkoutKind.stretch => const Color(0xFF9E9D24),
      };
}
