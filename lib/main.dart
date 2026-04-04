import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:talrun/app.dart';
import 'package:talrun/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Firebase Web דורש אפליקציית Web בקונסולה + firebase_options (flutterfire configure).
    // בלי זה Firebase.initializeApp() נכשל שקט — לרוב רואים מסך לבן.
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Text(
                    'TalRun בדפדפן עדיין לא מחובר ל-Firebase Web.\n\n'
                    'לפיתוח מומלץ: אמולטור אנדרואיד או מכשיר פיזי (שם Firebase כבר מוגדר).\n\n'
                    'לשמירת קוד: Ctrl+S בקבצים, ו-commit ב-Git כשמסיימים שינוי.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // runApp מיד — כדי שלא "יתקעו" על לוגו Flutter בזמן Firebase / SharedPreferences.
  runApp(const _StartupShell());
}

/// מסך טעינה קל, ואז מעבר ל־TalRunApp אחרי אתחול שירותים.
class _StartupShell extends StatefulWidget {
  const _StartupShell();

  @override
  State<_StartupShell> createState() => _StartupShellState();
}

class _StartupShellState extends State<_StartupShell> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await initializeDateFormatting('he_IL');
      final appState = AppState();
      await appState.load();
      await Firebase.initializeApp();
      if (!mounted) return;
      runApp(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const TalRunApp(),
        ),
      );
    } catch (e, st) {
      debugPrint('TalRun startup failed: $e\n$st');
      if (!mounted) return;
      runApp(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: SelectableText(
                    'שגיאת אתחול האפליקציה:\n\n$e\n\n'
                    '(אם זה Firebase — ודאו google-services.json וחיבור רשת)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.35),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFE8F4FC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TalRun',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 16),
              Text(
                'טוען…',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
