import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talrun/state/user_role.dart';

/// מצב אפליקציה: מאמן / מתאמן ותכנית פעילה.
/// נשמר מקומית; בעתיד אפשר להחליף ב-Firestore בלי לשנות את ה-UI.
class AppState extends ChangeNotifier {
  UserRole role = UserRole.trainee;
  bool hasActivePlan = false;

  static const _keyRole = 'talrun_user_role';
  static const _keyPlan = 'talrun_has_active_plan';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final ri = p.getInt(_keyRole);
    if (ri != null && ri >= 0 && ri < UserRole.values.length) {
      role = UserRole.values[ri];
    }
    // ברירת מחדל true כדי שלא ייראה שהאפליקציה "ריקה" אחרי התקנה (ניתן לכבות בהגדרות).
    hasActivePlan = p.getBool(_keyPlan) ?? true;
    notifyListeners();
  }

  Future<void> setRole(UserRole value) async {
    role = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyRole, value.index);
  }

  Future<void> setHasActivePlan(bool value) async {
    hasActivePlan = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyPlan, value);
  }
}
