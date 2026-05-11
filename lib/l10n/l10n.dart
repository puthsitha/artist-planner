import 'package:artistplanner/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:artistplanner/l10n/gen/app_localizations.dart';
export 'package:artistplanner/l10n/src/l10n_enum_ext.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
