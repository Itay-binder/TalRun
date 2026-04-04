import 'package:flutter/material.dart';

enum ManualActivityKind {
  run,
  walk,
  cycle,
  strength,
  mobility,
  other,
}

extension ManualActivityKindHe on ManualActivityKind {
  String get labelHe => switch (this) {
        ManualActivityKind.run => 'ריצה',
        ManualActivityKind.walk => 'הליכה',
        ManualActivityKind.cycle => 'אופניים',
        ManualActivityKind.strength => 'כוח',
        ManualActivityKind.mobility => 'מוביליטי / מתיחות',
        ManualActivityKind.other => 'אחר',
      };

  IconData get icon => switch (this) {
        ManualActivityKind.run => Icons.directions_run,
        ManualActivityKind.walk => Icons.directions_walk,
        ManualActivityKind.cycle => Icons.directions_bike,
        ManualActivityKind.strength => Icons.fitness_center,
        ManualActivityKind.mobility => Icons.self_improvement,
        ManualActivityKind.other => Icons.more_horiz,
      };
}
