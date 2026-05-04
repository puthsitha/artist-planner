enum ThemeColor {
  defaultTheme,
  brownTheme,
  pinkTheme;

  String get label {
    switch (this) {
      case ThemeColor.defaultTheme:
        return 'Midnight Black';
      case ThemeColor.brownTheme:
        return 'Warm Brown';
      case ThemeColor.pinkTheme:
        return 'Soft Pink';
    }
  }
}
