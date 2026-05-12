import 'dart:async';
import 'dart:developer';

import 'package:artistplanner/core/services/services.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Make sure the system status bar is visible and rendered as a transparent
  // overlay on top of the app. `edgeToEdge` lets our background image extend
  // beneath the bar; the overlay style makes the bar's icons white so they
  // stay readable on the dark glass UI.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarBrightness: Brightness.dark, // iOS — for a dark background
      statusBarIconBrightness: Brightness.light, // Android — light icons
      systemNavigationBarColor: Color(0x00000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local notifications (timezone DB + plugin).
  await NotificationService.instance.init();

  // Add cross-flavor configuration here

  runApp(await builder());
}
