import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/routes/src/not_found_screen.dart';
import 'package:artistplanner/core/routes/widget/bottom_bar.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/feature/calendar/calendar.dart';
import 'package:artistplanner/feature/dashboard/dashboard.dart';
import 'package:artistplanner/feature/goal/goal.dart';
import 'package:artistplanner/feature/on_boarding/on_boarding.dart';
import 'package:artistplanner/feature/setting/setting.dart';
import 'package:artistplanner/feature/splash/splash.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

enum Pages {
  /// splash
  splash,
  onboarding,
  app,

  /// dashboard
  dashboard,

  /// calendar
  calendar,

  /// goal
  goal,

  /// setting
  setting,
}

class AppRouter {
  AppRouter();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static late StatefulNavigationShell navigationBottomBarShell;

  static late ScrollController recordScrollController;

  static final dashboradShellNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'dashboard',
  );
  static final calenderShellNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'calender',
  );
  static final goalShellNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'goal',
  );
  static final settingShellNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'setting',
  );

  static GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (kDebugMode) {
        print('route fullPath : ${state.fullPath}');
      }
      return null;
    },
    errorPageBuilder: (context, state) {
      return NotFoundScreen.page(key: state.pageKey);
    },
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        name: Pages.splash.name,
        path: '/',
        pageBuilder: (context, state) {
          return SplashPage.page(key: state.pageKey);
        },
      ),
      GoRoute(
        name: Pages.onboarding.name,
        path: '/onboarding',
        pageBuilder: (context, state) {
          return OnBoardingPage.page(key: state.pageKey);
        },
      ),
      GoRoute(
        name: Pages.app.name,
        path: '/app',
        redirect: (context, state) {
          if (state.fullPath == '/app') {
            return '/app/dashboard';
          }
          return null;
        },
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              navigationBottomBarShell = navigationShell;
              return BottomNavigationPage(child: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: dashboradShellNavigatorKey,
                routes: [
                  GoRoute(
                    name: Pages.dashboard.name,
                    path: '/dashboard',
                    pageBuilder: (context, state) {
                      return DashboardPage.page(key: state.pageKey);
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: calenderShellNavigatorKey,
                routes: [
                  GoRoute(
                    name: Pages.calendar.name,
                    path: 'calendar',
                    pageBuilder: (context, state) {
                      return CalendarPage.page(key: state.pageKey);
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: goalShellNavigatorKey,
                routes: [
                  GoRoute(
                    path: 'goal',
                    parentNavigatorKey: goalShellNavigatorKey,
                    redirect: (context, state) {
                      if (state.fullPath == '/app/goal') {
                        return '/app/goal/goal-analytis';
                      }
                      return null;
                    },
                    routes: [
                      GoRoute(
                        name: Pages.goal.name,
                        parentNavigatorKey: goalShellNavigatorKey,
                        path: 'goal-analytis',
                        pageBuilder: (context, state) {
                          return GoalPage.page(key: state.pageKey);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: settingShellNavigatorKey,
                routes: [
                  GoRoute(
                    path: 'setting',
                    name: Pages.setting.name,
                    pageBuilder: (context, state) {
                      return SettingPage.page(key: state.pageKey);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class BottomNavigationPage extends StatelessWidget {
  const BottomNavigationPage({required this.child, super.key});

  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: LiquidGlassBottomBar(
          fake: false,
          spacing: Spacing.normal,
          horizontalPadding: Spacing.normal,
          bottomPadding: 0,
          barHeight: kBottomNavBarHeight,
          glassSettings: LiquidGlassSettings(),
          tabs: [
            LiquidGlassBottomBarTab(
              label: context.l10n.home,
              icon: Icons.dashboard_rounded,
            ),
            LiquidGlassBottomBarTab(
              label: context.l10n.calender,
              icon: Icons.calendar_month,
            ),
            LiquidGlassBottomBarTab(
              label: context.l10n.goal,
              icon: Icons.bar_chart_rounded,
            ),
            LiquidGlassBottomBarTab(
              label: context.l10n.setting,
              icon: Icons.settings_rounded,
            ),
          ],
          selectedIndex: child.currentIndex,
          onTabSelected: (index) {
            child.goBranch(index, initialLocation: index == child.currentIndex);
          },
        ),
      ),
      body: child,
    );
  }
}
