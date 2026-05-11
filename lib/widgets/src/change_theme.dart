import 'package:artistplanner/core/blocs/theme/theme_bloc.dart';
import 'package:artistplanner/core/enums/enums.dart';
import 'package:artistplanner/core/themes/themes.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class ChangeTheme extends StatefulWidget {
  const ChangeTheme({super.key});

  @override
  State<ChangeTheme> createState() => _ChangeThemeState();
}

class _ChangeThemeState extends State<ChangeTheme> {
  late ThemeColor _selectedTheme;

  @override
  void initState() {
    super.initState();
    final themeState = context.read<ThemeBloc>().state;
    _selectedTheme = themeState.selectTheme;
  }

  void _onSaveTheme() {
    context.read<ThemeBloc>().add(ThemeAppChange(theme: _selectedTheme));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidGlassLayer(
        fake: false,
        settings: LiquidGlassSettings(lightIntensity: 0),
        child: LiquidGlass.grouped(
          shape: const LiquidRoundedSuperellipse(borderRadius: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.choose_theme,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                RadioGroup<ThemeColor>(
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() {
                      _selectedTheme = value!;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final theme in ThemeColor.values)
                        _ThemeOption(theme: theme, label: theme.labelOf(l10n)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _onSaveTheme,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.theme, required this.label});

  final ThemeColor theme;
  final String label;

  Color get _themeColor {
    switch (theme) {
      case ThemeColor.defaultTheme:
        return AppColors.mintPrimary;
      case ThemeColor.brownTheme:
        return const Color(0xFFB8956A);
      case ThemeColor.pinkTheme:
        return const Color(0xFFE7A8FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _themeColor,
          borderRadius: BorderRadius.circular(Raduis.sm),
        ),
      ),
      title: Text(label),
      trailing: Radio<ThemeColor>(value: theme),
    );
  }
}
