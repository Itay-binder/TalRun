import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:talrun/data/demo_trainee_plan.dart';
import 'package:talrun/state/app_state.dart';
import 'package:talrun/theme/workout_colors.dart';
import 'package:talrun/state/user_role.dart';
import 'package:talrun/utils/calendar_he.dart';
import 'package:talrun/widgets/weekly_strip.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.role == UserRole.coach) {
      return const _CoachTodayBody();
    }
    return const _TraineeTodayBody();
  }
}

class _CoachTodayBody extends StatelessWidget {
  const _CoachTodayBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FC),
      appBar: AppBar(
        title: const Text('היום'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ממשק מאמן',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'כאן יוצגו המתאמנים, התכניות וההתקדמות שלהם. '
                'בשלב זה זה מסך מקום — נחבר לנתונים (Firestore) בהמשך.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                      height: 1.4,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.tonal(
                onPressed: () => context.push('/settings'),
                child: const Text('הגדרות וסוג משתמש'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraineeTodayBody extends StatelessWidget {
  const _TraineeTodayBody();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final weekStart = startOfWeekSunday(now);
    final dayNumbers =
        List.generate(7, (i) => weekStart.add(Duration(days: i)).day);
    final selectedIndex = weekdayIndexFromSunday(now);
    final markers = markersForTrainee(app.hasActivePlan);
    final slot = app.hasActivePlan ? todaySlotFor(now) : null;

    final headline = !app.hasActivePlan
        ? 'אין תכנית פעילה'
        : (slot == null ? 'יום מנוחה' : slot.title);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FC),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.push('/settings'),
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.deepPurple.shade200,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Text(
                              (user?.displayName ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const Spacer(),
                  if (app.hasActivePlan) ...[
                    Text(
                      'שבוע $demoWeekCurrent/$demoWeekTotal',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push('/calendar'),
                      icon: const Icon(Icons.calendar_month_outlined),
                      tooltip: 'לוח אימונים',
                    ),
                  ] else
                    TextButton(
                      onPressed: () {
                        /* יצירת תכנית — בהמשך */
                      },
                      child: const Text('צור תכנית'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: WeeklyStrip(
                    labels: kHebrewWeekdayShort,
                    dayNumbers: dayNumbers,
                    selectedIndex: selectedIndex,
                    markersByDayIndex: markers,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (app.hasActivePlan &&
                        slot != null &&
                        slot.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        slot.subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54),
                      ),
                    ],
                    if (!app.hasActivePlan) ...[
                      const SizedBox(height: 12),
                      Text(
                        'צור תכנית או בקש מהמאמן שלך שיישם לך תכנית — '
                        'אז יופיעו כאן האימונים בשבוע.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54, height: 1.35),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (app.hasActivePlan && slot != null)
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => context.push('/workout/today'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: slot.kind.color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'אימון היום',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        slot.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Directionality.of(context) == TextDirection.rtl
                                      ? Icons.chevron_left
                                      : Icons.chevron_right,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width - 32,
          child: FilledButton.icon(
            onPressed: () => _showStartSheet(context, app.hasActivePlan),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'התחל אימון',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void _showStartSheet(BuildContext context, bool hasPlan) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('אימון מהתכנית להיום'),
                enabled: hasPlan,
                subtitle: hasPlan
                    ? null
                    : const Text('זמין כשיש תכנית פעילה',
                        style: TextStyle(fontSize: 12)),
                onTap: hasPlan
                    ? () {
                        Navigator.pop(ctx);
                        ctx.push('/workout/today');
                      }
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('אימון חופשי'),
                onTap: () {
                  Navigator.pop(ctx);
                  ctx.push('/workout/free');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
