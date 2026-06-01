import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/routes/routes.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:artistplanner/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  static MaterialPage<void> page({Key? key}) =>
      MaterialPage<void>(child: SettingPage(key: key));

  @override
  Widget build(BuildContext context) {
    return const SettingView();
  }
}

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  Future<void> _showLanguageDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const ChangeLanguage(),
    );
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const ChangeTheme(),
    );
  }

  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    final version = kDebugMode
        ? '${info.version}+${info.buildNumber}'
        : info.version;

    return version;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isGlassUI = context.watch<ThemeBloc>().state.isGlassUI;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.transparent,
        title: Text(l10n.setting, style: TextStyle(color: AppColors.white)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: kBottomNavBarHeight + Spacing.l,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight - (kBottomNavBarHeight + Spacing.l),
              ),
              child: IntrinsicHeight(
                child: LiquidGlassLayer(
                  fake: !isGlassUI,
                  settings: LiquidGlassSettings(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.normal,
                        ),
                        child: Column(
                          spacing: Spacing.normal,
                          children: [
                            Image.asset(ImagePaths.transparentLogo, width: 200),
                            LiquidStretch(
                              child: LiquidGlass.grouped(
                                shape: LiquidRoundedSuperellipse(
                                  borderRadius: 20,
                                ),
                                child: GlassGlow(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    child: ListTile(
                                      shape: BeveledRectangleBorder(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(20),
                                      ),
                                      leading: const Icon(
                                        Icons.language,
                                        size: 40,
                                        color: Colors.tealAccent,
                                      ),
                                      title: Text(
                                        l10n.language,
                                        style: context.textTheme.titleLarge,
                                      ),
                                      subtitle: Text(
                                        l10n.press_here_change_language,
                                        style: context.textTheme.bodyLarge,
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                      ),
                                      onTap: () => _showLanguageDialog(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            LiquidStretch(
                              child: LiquidGlass.grouped(
                                shape: LiquidRoundedSuperellipse(
                                  borderRadius: 20,
                                ),
                                child: GlassGlow(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    child: ListTile(
                                      shape: BeveledRectangleBorder(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(20),
                                      ),
                                      leading: const Icon(
                                        Icons.color_lens_rounded,
                                        size: 40,
                                        color: Colors.indigoAccent,
                                      ),
                                      title: Text(
                                        l10n.theme,
                                        style: context.textTheme.titleLarge,
                                      ),
                                      subtitle: Text(
                                        l10n.customize_theme_appearance,
                                        style: context.textTheme.bodyLarge,
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                      ),
                                      onTap: () => _showThemeDialog(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            LiquidStretch(
                              child: LiquidGlass.grouped(
                                shape: LiquidRoundedSuperellipse(
                                  borderRadius: 20,
                                ),
                                child: GlassGlow(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    child: ListTile(
                                      shape: BeveledRectangleBorder(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(20),
                                      ),
                                      leading: const Icon(
                                        Icons.notifications_active_rounded,
                                        size: 40,
                                        color: Color(0xFFFFC857),
                                      ),
                                      title: Text(
                                        l10n.notifications_title,
                                        style: context.textTheme.titleLarge,
                                      ),
                                      subtitle: Text(
                                        l10n.notifications_subtitle,
                                        style: context.textTheme.bodyLarge,
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                      ),
                                      onTap: () => context.pushNamed(
                                        Pages.notificationSetting.name,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            LiquidStretch(
                              child: LiquidGlass.grouped(
                                shape: LiquidRoundedSuperellipse(
                                  borderRadius: 20,
                                ),
                                child: GlassGlow(
                                  child: SwitchListTile.adaptive(
                                    shape: BeveledRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(20),
                                    ),
                                    secondary: const Icon(
                                      Icons.auto_awesome,
                                      size: 40,
                                      color: Color(0xFFE7A8FF),
                                    ),
                                    title: Text(
                                      l10n.glass_ui,
                                      style: context.textTheme.titleLarge,
                                    ),
                                    subtitle: Text(
                                      isGlassUI
                                          ? l10n.glass_ui_on
                                          : l10n.glass_ui_off,
                                      style: context.textTheme.bodyLarge,
                                    ),
                                    value: isGlassUI,
                                    activeTrackColor: context.colors.primary,
                                    onChanged: (value) => context
                                        .read<ThemeBloc>()
                                        .add(ThemeGlassToggled(enabled: value)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: FutureBuilder<String>(
                            future: getAppVersion(),
                            builder: (context, snapshot) {
                              final version = snapshot.data ?? '';
                              return Text(
                                '${l10n.copyright} © ${l10n.version} $version',
                                style: context.textTheme.titleMedium,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
