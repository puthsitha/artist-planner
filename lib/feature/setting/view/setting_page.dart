import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/extensions/extensions.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:artistplanner/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: Column(
        children: [
          Column(
            children: [
              Image.asset(ImagePaths.transparentLogo, width: 200),
              ListTile(
                leading: const Icon(
                  Icons.language,
                  size: 40,
                  color: Colors.tealAccent,
                ),
                title: Text(l10n.language, style: context.textTheme.titleLarge),
                subtitle: Text(
                  l10n.press_here_change_language,
                  style: context.textTheme.bodyLarge,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showLanguageDialog(context),
              ),
              const SizedBox(height: Spacing.sm),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return ListTile(
                    leading: Icon(
                      themeState.selectTheme == ThemeColor.defaultTheme
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      size: 40,
                      color: themeState.selectTheme == ThemeColor.defaultTheme
                          ? Colors.indigoAccent
                          : Colors.amberAccent,
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
                    onTap: () => null,
                    // Switch(
                    //   value: themeState.selectTheme == ThemeColor.defaultTheme,
                    //   onChanged: (value) {
                    //     final newTheme = value
                    //         ? ThemeColor.defaultTheme
                    //         : ThemeColor.brownTheme;
                    //     context.read<ThemeBloc>().add(
                    //       ThemeAppChange(theme: newTheme),
                    //     );
                    //   },
                    // ),
                  );
                },
              ),
            ],
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
    );
  }
}
