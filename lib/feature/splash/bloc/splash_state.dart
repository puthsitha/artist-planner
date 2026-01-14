part of 'splash_bloc.dart';

abstract class SplashState {
  const SplashState();
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashInitialized extends SplashState {
  // <-- Keep the persisted value

  const SplashInitialized({
    required this.initialPage,
    required this.isFirstRun,
  });

  factory SplashInitialized.fromMap(Map<String, dynamic> map) {
    return SplashInitialized(
      initialPage: Pages.values.firstWhere((e) => e.name == map['initialPage']),
      isFirstRun: map['isFirstRun'] as bool,
    );
  }
  final Pages initialPage;
  final bool isFirstRun;

  // Serialization
  Map<String, dynamic> toMap() {
    return {'initialPage': initialPage.name, 'isFirstRun': isFirstRun};
  }
}
