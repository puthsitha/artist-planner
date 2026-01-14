import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:artistplanner/feature/splash/bloc/splash_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: SplashPage(key: key));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => SplashBloc(), child: const SplashView());
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    Future.delayed(
      const Duration(milliseconds: 100),
      FlutterNativeSplash.remove,
    );
    super.dispose();
  }

  void init() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashBloc>().add(const SplashInit());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashInitialized) {
          context.goNamed(state.initialPage.name);
          // context.goNamed(Pages.onboarding.name);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.primaryBg,
        body: const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
