import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// כרטיס מצב רוח: שמאל = לא טוב, ימין = טוב. מעבר מעל חצי לשמאל → דיאלוג התייעצות עם מאמן.
class TraineeWellnessMoodCard extends StatefulWidget {
  const TraineeWellnessMoodCard({super.key});

  @override
  State<TraineeWellnessMoodCard> createState() => _TraineeWellnessMoodCardState();
}

class _TraineeWellnessMoodCardState extends State<TraineeWellnessMoodCard> {
  /// 0 = חולה/לא טוב (שמאל), 1 = שמח (ימין)
  double _mood = 0.65;
  double? _dragStartValue;

  static const _sickColor = Color(0xFF5C6BC0);
  static const _happyColor = Color(0xFF43A047);

  void _onSliderEnd(BuildContext context, double value) {
    final start = _dragStartValue ?? value;
    _dragStartValue = null;
    if (value < 0.5 && start >= 0.5) {
      _showCoachConsultDialog(context);
    }
  }

  Future<void> _showCoachConsultDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.support_agent, size: 40, color: Colors.blue.shade700),
        title: const Text('להתייעץ עם המאמן?'),
        content: const Text(
          'נראה שהיום זה פחות בשבילך.\n'
          'האם תרצה להתייעץ עם המאמן שלך?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('לא עכשיו'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('בהמשך: שליחת בקשה למאמן (צ׳אט / התראה)'),
                ),
              );
            },
            child: const Text('כן, בואו נדבר'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'איך אתה מרגיש היום?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'גרור את הגלילה: ימין שמח · שמאל פחות טוב',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black45,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.sick_rounded,
                  size: 36,
                  color: Color.lerp(_sickColor, Colors.grey, 1 - _mood)!
                      .withValues(alpha: 0.85 + 0.15 * (1 - _mood)),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      activeTrackColor: Color.lerp(_sickColor, _happyColor, _mood),
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.white,
                      overlayColor: _happyColor.withValues(alpha: 0.15),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 15,
                        elevation: 2,
                        pressedElevation: 4,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,
                      ),
                    ),
                    child: Slider(
                      value: _mood.clamp(0.0, 1.0),
                      onChangeStart: (v) => _dragStartValue = v,
                      onChanged: (v) => setState(() => _mood = v),
                      onChangeEnd: (v) => _onSliderEnd(context, v),
                    ),
                  ),
                ),
                Icon(
                  Icons.sentiment_very_satisfied_rounded,
                  size: 36,
                  color: Color.lerp(_sickColor, _happyColor, _mood)!
                      .withValues(alpha: 0.85 + 0.15 * _mood),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
