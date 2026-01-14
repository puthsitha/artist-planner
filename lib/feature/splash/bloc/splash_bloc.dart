import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:artistplanner/core/routes/routes.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends HydratedBloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<SplashInit>(_onInit);
  }

  void _onInit(SplashInit event, Emitter<SplashState> emit) {
    final currentState = state;

    if (currentState is SplashInitialized) {
      // Already initialized before
      emit(const SplashInitialized(initialPage: Pages.app, isFirstRun: false));
      return;
    }

    // First time app opened
    emit(
      const SplashInitialized(initialPage: Pages.onboarding, isFirstRun: true),
    );
  }

  // -------------------------------
  // Hydrated overrides
  // -------------------------------
  @override
  SplashState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['type'] == 'initialized') {
        return SplashInitialized.fromMap(json['data'] as Map<String, dynamic>);
      }
      return const SplashInitial();
    } on Exception catch (_) {
      return const SplashInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(SplashState state) {
    if (state is SplashInitialized) {
      return {'type': 'initialized', 'data': state.toMap()};
    }
    return null;
  }
}
