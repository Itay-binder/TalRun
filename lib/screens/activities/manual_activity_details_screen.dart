import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:talrun/screens/activities/manual_activity_kind.dart';

/// פרטי פעילות ידנית (דמו — שמירה ל־Firestore בהמשך).
class ManualActivityDetailsScreen extends StatefulWidget {
  const ManualActivityDetailsScreen({super.key, required this.kind});

  final ManualActivityKind kind;

  @override
  State<ManualActivityDetailsScreen> createState() =>
      _ManualActivityDetailsScreenState();
}

class _ManualActivityDetailsScreenState
    extends State<ManualActivityDetailsScreen> {
  late DateTime _date;
  final _titleCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _durationMinCtrl = TextEditingController(text: '30');
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _distanceCtrl.dispose();
    _durationMinCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('he', 'IL'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('הפעילות נשמרה (דמו — עדיין לא נשלח לשרת)')),
    );
    context.pop();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kind;
    final dateStr = DateFormat.yMMMd('he_IL').format(_date);

    return Scaffold(
      appBar: AppBar(
        title: Text('${k.labelHe} — פרטים'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('תאריך'),
            subtitle: Text(dateStr),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'כותרת (אופציונלי)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (k == ManualActivityKind.run ||
              k == ManualActivityKind.walk ||
              k == ManualActivityKind.cycle) ...[
            TextField(
              controller: _distanceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'מרחק (ק״מ)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _durationMinCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'משך (דקות)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'הערות',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('שמירה'),
          ),
        ],
      ),
    );
  }
}
