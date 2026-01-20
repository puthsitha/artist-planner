import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:artistplanner/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.transparent,
        title: Text(l10n.setting),
      ),
      body: LiquidGlassLayer(
        fake: false,
        settings: LiquidGlassSettings(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.normal),
              child: Column(
                spacing: Spacing.normal,
                children: [
                  Image.asset(ImagePaths.transparentLogo, width: 200),
                  LiquidStretch(
                    child: LiquidGlass.grouped(
                      shape: LiquidRoundedSuperellipse(borderRadius: 20),
                      child: GlassGlow(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: ListTile(
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
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _showLanguageDialog(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  LiquidStretch(
                    child: LiquidGlass.grouped(
                      shape: LiquidRoundedSuperellipse(borderRadius: 20),
                      child: GlassGlow(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: ListTile(
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
                            trailing: const Icon(Icons.arrow_forward_ios),
                            // onTap: () => _showLanguageDialog(context),
                          ),
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
    );
  }
}
