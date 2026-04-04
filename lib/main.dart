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

  await initializeDateFormatting('he_IL');
  final appState = AppState();
  await appState.load();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const TalRunApp(),
    ),
  );
}
