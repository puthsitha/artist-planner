import 'package:artistplanner/core/themes/themes.dart';
import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  AppColorScheme get colors {
    return Theme.of(this).extension<AppColorScheme>()!;
  }

  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }
}
