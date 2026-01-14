import 'package:artistplanner/core/blocs/lang/language_bloc.dart';
import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/routes/routes.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    _initSplashScreen();
    super.initState();
  }

  void _initSplashScreen() {
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = AppRouter.router;
    // Randomize background
    final bgCandidates = <String>[
      ImagePaths.bg,
      ImagePaths.bg1,
      ImagePaths.bg2,
      ImagePaths.bg3,
    ]..removeWhere((e) => e.isEmpty);

    final bg = bgCandidates.isNotEmpty
        ? bgCandidates[Random().nextInt(bgCandidates.length)]
        : '';
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LanguageBloc()),
        BlocProvider(create: (context) => ThemeBloc()),
      ],
      child: Builder(
        builder: (context) {
          final languageState = context.watch<LanguageBloc>().state;
          final themeState = context.watch<ThemeBloc>().state;
          Intl.defaultLocale =
              languageState.selectLanguage == const Locale('km')
              ? 'km_KH'
              : 'en_US';

          return GestureDetector(
            onTap: () {
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            },
            child: MaterialApp.router(
              // showPerformanceOverlay: true, // show performance overlay
              theme: themeState.selectTheme == ThemeColor.defaultTheme
                  ? defaultTheme
                  : brownTheme,
              locale: languageState.selectLanguage,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: goRouter,
              builder: (context, child) {
                final childToast = MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.noScaling),
                  child: child!,
                );

                if (bg.isEmpty) return childToast;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: Image.asset(bg, fit: BoxFit.cover)),
                    childToast,
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
