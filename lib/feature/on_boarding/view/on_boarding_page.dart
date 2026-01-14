import 'package:artistplanner/core/blocs/lang/language_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/routes/routes.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:artistplanner/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class OnboardingContent {
  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
  final String image;
  final String title;
  final String description;
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: OnBoardingPage(key: key));

  @override
  Widget build(BuildContext context) {
    return const OnBoardingView();
  }
}

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  late List<OnboardingContent> _contents;

  late final PageController _controller;
  int _current = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    _contents = [
      OnboardingContent(
        image: ImagePaths.onboarding1,
        title: l10n.onboarding_title_1,
        description: l10n.onboarding_content_1,
      ),
      OnboardingContent(
        image: ImagePaths.onboarding2,
        title: l10n.onboarding_title_2,
        description: l10n.onboarding_content_2,
      ),
      OnboardingContent(
        image: ImagePaths.onboarding3,
        title: l10n.onboarding_title_3,
        description: l10n.onboarding_content_3,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_current == _contents.length - 1) {
      context.goNamed(Pages.app.name);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _contents.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, index) {
                  final item = _contents[index];
                  return Column(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.normal,
                          ),
                          child: LiquidGlass.withOwnLayer(
                            shape: const LiquidRoundedRectangle(
                              borderRadius: Raduis.xl,
                            ),
                            settings: const LiquidGlassSettings(),
                            child: Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.normal),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.normal,
                          ),
                          child: LiquidGlass.withOwnLayer(
                            shape: const LiquidRoundedRectangle(
                              borderRadius: Raduis.xl,
                            ),
                            settings: const LiquidGlassSettings(),
                            child: Padding(
                              padding: const EdgeInsets.all(Spacing.normal),
                              child: Column(
                                spacing: Spacing.normal,
                                crossAxisAlignment: .start,
                                children: [
                                  Row(
                                    mainAxisAlignment: .spaceBetween,
                                    children: [
                                      Text(
                                        item.title,
                                        style: context.textTheme.displaySmall,
                                      ),
                                      BlocBuilder<LanguageBloc, LanguageState>(
                                        builder: (context, langState) {
                                          return Row(
                                            spacing: Spacing.m,
                                            children: [
                                              ScaleButton(
                                                onTap: () {
                                                  context
                                                      .read<LanguageBloc>()
                                                      .add(
                                                        LanguageAppChange(
                                                          locale: const Locale(
                                                            'km',
                                                          ),
                                                        ),
                                                      );
                                                },
                                                child: CircleAvatar(
                                                  radius: Raduis.l,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            langState
                                                                    .selectLanguage ==
                                                                const Locale(
                                                                  'km',
                                                                )
                                                            ? context
                                                                  .colors
                                                                  .pureWhite
                                                            : context
                                                                  .colors
                                                                  .transparent,
                                                        width: 2,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  backgroundImage: AssetImage(
                                                    ImagePaths.kmFlag,
                                                  ),
                                                ),
                                              ),
                                              ScaleButton(
                                                onTap: () {
                                                  context
                                                      .read<LanguageBloc>()
                                                      .add(
                                                        LanguageAppChange(
                                                          locale: const Locale(
                                                            'en',
                                                          ),
                                                        ),
                                                      );
                                                },
                                                child: CircleAvatar(
                                                  radius: Raduis.l,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            langState
                                                                    .selectLanguage ==
                                                                const Locale(
                                                                  'en',
                                                                )
                                                            ? context
                                                                  .colors
                                                                  .pureWhite
                                                            : context
                                                                  .colors
                                                                  .transparent,
                                                        width: 2,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  backgroundImage: AssetImage(
                                                    ImagePaths.enFlag,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.description,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.normal),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: List.generate(
                                          _contents.length,
                                          (i) => AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            width: _current == i ? 18 : 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _current == i
                                                  ? context.colors.primary
                                                  : context.colors.primary
                                                        .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Raduis.normal,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _onNextPressed,
                                        child: LiquidGlass(
                                          shape: const LiquidRoundedRectangle(
                                            borderRadius: Raduis.l,
                                          ),
                                          glassContainsChild: true,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: Spacing.normal,
                                              vertical: Spacing.sm,
                                            ),
                                            child: Text(
                                              _current == _contents.length - 1
                                                  ? l10n.get_started
                                                  : l10n.next,
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
