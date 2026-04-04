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

  // runApp פעם אחת בלבד — קריאה שנייה ל-runApp עלולה לנתק את הדיבאגר ולגרום ל-Run להסתיים.
  runApp(const TalRunBootstrap());
}

enum _BootstrapPhase { loading, ready, error }

/// שורש יחיד: טעינה → Provider + TalRunApp (בלי להחליף את מנוע Flutter).
class TalRunBootstrap extends StatefulWidget {
  const TalRunBootstrap({super.key});

  @override
  State<TalRunBootstrap> createState() => _TalRunBootstrapState();
}

class _TalRunBootstrapState extends State<TalRunBootstrap> {
  _BootstrapPhase _phase = _BootstrapPhase.loading;
  Object? _error;
  StackTrace? _stackTrace;
  AppState? _appState;

  static const _firebaseTimeout = Duration(seconds: 30);

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
      await Firebase.initializeApp().timeout(_firebaseTimeout);
      if (!mounted) return;
      setState(() {
        _appState = appState;
        _phase = _BootstrapPhase.ready;
      });
    } catch (e, st) {
      debugPrint('TalRun startup failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e;
        _stackTrace = st;
        _phase = _BootstrapPhase.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _BootstrapPhase.loading:
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
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'אם זה נשאר כאן זמן רב — בדקו רשת, עדכנו את Google Play Services, '
                      'או הריצו מטרמינל: flutter run -v',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black38,
                            height: 1.35,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case _BootstrapPhase.error:
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: SelectableText(
                    'שגיאת אתחול האפליקציה:\n\n$_error\n\n'
                    'Stack trace (לדיבוג):\n$_stackTrace\n\n'
                    'טיפים: חיבור אינטרנט, google-services.json, עדכון Play Services.',
                    style: const TextStyle(height: 1.35),
                  ),
                ),
              ),
            ),
          ),
        );
      case _BootstrapPhase.ready:
        return ChangeNotifierProvider<AppState>.value(
          value: _appState!,
          child: const TalRunApp(),
        );
    }
  }
}
