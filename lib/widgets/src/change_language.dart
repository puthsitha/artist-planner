import 'package:artistplanner/core/blocs/lang/language_bloc.dart';
import 'package:artistplanner/core/common/common.dart';
import 'package:artistplanner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({super.key});

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  late Locale _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final languageState = context.read<LanguageBloc>().state;
    _selectedLanguage = languageState.selectLanguage;
  }

  void _onSaveLanguage() {
    context.read<LanguageBloc>().add(
      LanguageAppChange(locale: _selectedLanguage),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidGlassLayer(
        fake: false,
        settings: LiquidGlassSettings(
          // glassColor: Color.from(alpha: .1, red: 1, green: 1, blue: 1),
          saturation: 2,
          refractiveIndex: 5,
          thickness: 50,
          lightIntensity: 0.2,
          // chromaticAberration: 1,
          blur: 10,
        ),
        child: LiquidGlass.grouped(
          shape: const LiquidRoundedSuperellipse(borderRadius: 16),
          child: GlassGlow(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<Locale>(
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LanguageOption(
                          locale: Locale('km'),
                          label: 'ខ្មែរ',
                          image: ImagePaths.kmFlag,
                        ),
                        _LanguageOption(
                          locale: Locale('en'),
                          label: 'English',
                          image: ImagePaths.enFlag,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LiquidGlass.grouped(
                        shape: const LiquidRoundedSuperellipse(borderRadius: 8),
                        child: GlassGlow(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassGlow(
                        child: ElevatedButton(
                          onPressed: _onSaveLanguage,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(l10n.save),
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
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.locale,
    required this.label,
    required this.image,
  });

  final Locale locale;
  final String label;
  final String image;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(image, width: 30, height: 20, fit: BoxFit.cover),
      ),
      title: Text(label),
      trailing: Radio<Locale>(value: locale),
    );
  }
}
