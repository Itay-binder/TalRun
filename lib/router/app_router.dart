import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talrun/router/go_router_refresh_stream.dart';
import 'package:talrun/screens/activities/activities_screen.dart';
import 'package:talrun/screens/activities/manual_activity_details_screen.dart';
import 'package:talrun/screens/activities/manual_activity_kind.dart';
import 'package:talrun/screens/activities/manual_activity_type_screen.dart';
import 'package:talrun/screens/auth/sign_in_screen.dart';
import 'package:talrun/screens/calendar/training_calendar_screen.dart';
import 'package:talrun/screens/community/community_screen.dart';
import 'package:talrun/screens/integrations/connected_apps_screen.dart';
import 'package:talrun/screens/pace/pace_insights_screen.dart';
import 'package:talrun/screens/plan/plan_screen.dart';
import 'package:talrun/screens/settings/settings_screen.dart';
import 'package:talrun/screens/shell/main_shell.dart';
import 'package:talrun/screens/today/today_screen.dart';
import 'package:talrun/screens/workout/workout_detail_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter createAppRouter() {
  final refresh = GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/today',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      if (!loggedIn) {
        if (loc == '/sign-in') return null;
        return '/sign-in';
      }
      if (loggedIn && loc == '/sign-in') return '/today';
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plan',
                builder: (context, state) => const PlanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activities',
                builder: (context, state) => const ActivitiesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                builder: (context, state) => const CommunityScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/calendar',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TrainingCalendarScreen(),
      ),
      GoRoute(
        path: '/integrations',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ConnectedAppsScreen(),
      ),
      GoRoute(
        path: '/pace-insights',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PaceInsightsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/workout/:workoutId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['workoutId'] ?? '';
          return WorkoutDetailScreen(workoutId: id);
        },
      ),
      GoRoute(
        path: '/manual-activity/type',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ManualActivityTypeScreen(),
      ),
      GoRoute(
        path: '/manual-activity/details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          final kind = extra is ManualActivityKind
              ? extra
              : ManualActivityKind.run;
          return ManualActivityDetailsScreen(kind: kind);
        },
      ),
    ],
  );
}
