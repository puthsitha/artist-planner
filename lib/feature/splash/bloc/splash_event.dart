part of 'splash_bloc.dart';

abstract class SplashEvent {
  const SplashEvent();
}

class SplashInit extends SplashEvent {
  const SplashInit();
}
