import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const secondary = Color(0xFF5B4B8A);
  static const black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0x00f6f7fb);
  static const primaryText = Color(0xFFE5E7EB);
  static const secondaryText = Color(0xFF8F96B1);
  static const primaryBg = Color(0xFF0F172A);
  static const secondaryBg = Color(0xFF1B1625);
  //purple
  static const purpleLight = Color(0xFF8C6FF7);
  static const purplePrimary = Color(0xFF5A31F4);
  static const purpleDark = Color(0xFF3F22AB);
  //orange
  static const orangeLight = Color(0xFFFFF0DD);
  static const orangePrimary = Color(0xFFFF9F21);
  //green
  static const greenLight = Color(0xFF5BD51E);
  static const greenPrimary = Color(0xFF60BA62);
  static const greenDark = Color(0xFF4AC272);
  //yellow
  static const yellowPrimary = Color(0xFFFFB323);
  //blue
  static const darkCyanBlue = Color(0xFF2C5054);
  static const blueLight = Color(0xFF4F6FB4);
  //red
  static const redPrimary = Color(0xFFFC3B3B);

  // grey shades
  static const pureWhite = Color(0xFFFFFFFF);
  static const lightShadeGrey10 = Color(0xFFF7F9FA);
  static const lightShadeGrey20 = Color(0xFFF2F4F5);
  static const lightShadeGrey30 = Color(0xFFE3E5E5);
  static const lightShadeGrey40 = Color(0xFFCDCFD0);
  static const lightShadeGrey50 = Color(0xFF979C9E);

  static const pureDark = Color(0xFF090A0A);
  static const darkShadeGrey100 = Color(0xFF202325);
  static const darkShadeGrey90 = Color(0xFF303437);
  static const darkShadeGrey80 = Color(0xFF404446);
  static const darkShadeGrey70 = Color(0xFF6C7072);
  static const darkShadeGrey60 = Color(0xFF72777A);
}

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  AppColorScheme({
    required this.primary,
    required this.secondary,
    required this.transparent,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryBg,
    required this.secondaryBg,
    required this.purpleLight,
    required this.purplePrimary,
    required this.purpleDark,
    required this.orangeLight,
    required this.orangePrimary,
    required this.greenLight,
    required this.greenPrimary,
    required this.greenDark,
    required this.darkCyanBlue,
    required this.blueLight,
    required this.greyLight,
    required this.redPrimary,
    required this.greyPrimary,
    required this.greySecondary,
    required this.greyDark,
    required this.darkShadeGrey100,
    required this.darkShadeGrey60,
    required this.darkShadeGrey70,
    required this.darkShadeGrey80,
    required this.darkShadeGrey90,
    required this.lightShadeGrey10,
    required this.lightShadeGrey20,
    required this.lightShadeGrey30,
    required this.lightShadeGrey40,
    required this.lightShadeGrey50,
    required this.pureDark,
    required this.pureWhite,
    required this.divider,
    this.foodHomeAppBar,
  });

  /// Main primary color
  final Color primary;
  final Color primaryText;
  final Color primaryBg;

  /// Main secondary color
  final Color secondary;
  final Color secondaryText;
  final Color secondaryBg;

  final Color transparent;

  //purple
  final Color purpleLight;
  final Color purplePrimary;
  final Color purpleDark;
  //orange
  final Color orangeLight;
  final Color orangePrimary;
  //green
  final Color greenLight;
  final Color greenPrimary;
  final Color greenDark;
  //Blue
  final Color darkCyanBlue;
  final Color blueLight;
  //grey
  final Color greyLight;
  final Color greyPrimary;
  final Color greySecondary;
  final Color greyDark;
  //red
  final Color redPrimary;
  // Shades
  final Color pureWhite;
  final Color lightShadeGrey10;
  final Color lightShadeGrey20;
  final Color lightShadeGrey30;
  final Color lightShadeGrey40;
  final Color lightShadeGrey50;

  final Color pureDark;
  final Color darkShadeGrey100;
  final Color darkShadeGrey90;
  final Color darkShadeGrey80;
  final Color darkShadeGrey70;
  final Color darkShadeGrey60;
  final Color divider;

  // Background
  final Color? foodHomeAppBar;

  @override
  ThemeExtension<AppColorScheme> lerp(
    covariant ThemeExtension<AppColorScheme>? other,
    double t,
  ) {
    if (identical(this, other)) {
      return this;
    }
    return AppColorScheme(
      primary: primary,
      primaryText: primaryText,
      secondary: secondary,
      secondaryText: secondaryText,
      transparent: transparent,
      primaryBg: primaryBg,
      secondaryBg: secondaryBg,
      purpleLight: purpleLight,
      purplePrimary: purplePrimary,
      purpleDark: purpleDark,
      orangeLight: orangeLight,
      orangePrimary: orangePrimary,
      greenLight: greenLight,
      greenPrimary: greenPrimary,
      greenDark: greenDark,
      darkCyanBlue: darkCyanBlue,
      blueLight: blueLight,
      greyLight: greyLight,
      redPrimary: redPrimary,
      greyPrimary: greyPrimary,
      greySecondary: greySecondary,
      greyDark: greyDark,
      darkShadeGrey100: darkShadeGrey100,
      darkShadeGrey60: darkShadeGrey60,
      darkShadeGrey70: darkShadeGrey70,
      darkShadeGrey80: darkShadeGrey80,
      darkShadeGrey90: darkShadeGrey90,
      pureDark: pureDark,
      pureWhite: pureWhite,
      lightShadeGrey10: lightShadeGrey10,
      lightShadeGrey20: lightShadeGrey20,
      lightShadeGrey30: lightShadeGrey30,
      lightShadeGrey40: lightShadeGrey40,
      lightShadeGrey50: lightShadeGrey50,
      foodHomeAppBar: foodHomeAppBar,
      divider: divider,
    );
  }

  @override
  AppColorScheme copyWith({
    Color? primary,
    Color? secondary,
    Color? primaryText,
    Color? secondaryText,
    Color? primaryBg,
    Color? secondaryBg,
    Color? purpleLight,
    Color? purplePrimary,
    Color? purpleDark,
    Color? orangeLight,
    Color? orangePrimary,
    Color? greenLight,
    Color? greenPrimary,
    Color? greenDark,
    Color? transparent,
    Color? darkCyanBlue,
    Color? blueLight,
    Color? greyLight,
    Color? redPrimary,
    Color? greyPrimary,
    Color? greySecondary,
    Color? greyDark,
    Color? darkShadeGrey100,
    Color? darkShadeGrey60,
    Color? darkShadeGrey70,
    Color? darkShadeGrey80,
    Color? darkShadeGrey90,
    Color? lightShadeGrey10,
    Color? lightShadeGrey20,
    Color? lightShadeGrey30,
    Color? lightShadeGrey40,
    Color? lightShadeGrey50,
    Color? pureDark,
    Color? pureWhite,
    Color? mainBgPath,
    Color? divider,
  }) {
    return AppColorScheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      primaryBg: primaryBg ?? this.primaryBg,
      secondaryBg: secondaryBg ?? this.secondaryBg,
      orangePrimary: orangeLight ?? this.orangePrimary,
      purpleLight: purpleLight ?? this.purpleLight,
      purplePrimary: purplePrimary ?? this.purplePrimary,
      purpleDark: purpleDark ?? this.purpleDark,
      orangeLight: orangeLight ?? this.orangeLight,
      greenLight: greenLight ?? this.greenLight,
      greenPrimary: greenPrimary ?? this.greenPrimary,
      greenDark: greenDark ?? this.greenDark,
      transparent: transparent ?? this.transparent,
      darkCyanBlue: darkCyanBlue ?? this.darkCyanBlue,
      blueLight: blueLight ?? this.blueLight,
      greyLight: greyLight ?? this.greyLight,
      redPrimary: redPrimary ?? this.redPrimary,
      greyPrimary: greyPrimary ?? this.greyPrimary,
      greySecondary: greySecondary ?? this.greySecondary,
      greyDark: greyDark ?? this.greyDark,
      darkShadeGrey100: darkShadeGrey100 ?? this.darkShadeGrey100,
      darkShadeGrey60: darkShadeGrey60 ?? this.darkShadeGrey60,
      darkShadeGrey70: darkShadeGrey70 ?? this.darkShadeGrey70,
      darkShadeGrey80: darkShadeGrey80 ?? this.darkShadeGrey80,
      darkShadeGrey90: darkShadeGrey90 ?? this.darkShadeGrey90,
      lightShadeGrey10: lightShadeGrey10 ?? this.lightShadeGrey10,
      lightShadeGrey20: lightShadeGrey20 ?? this.lightShadeGrey20,
      lightShadeGrey30: lightShadeGrey30 ?? this.lightShadeGrey30,
      lightShadeGrey40: lightShadeGrey40 ?? this.lightShadeGrey40,
      lightShadeGrey50: lightShadeGrey50 ?? this.lightShadeGrey50,
      pureDark: pureDark ?? this.pureDark,
      pureWhite: pureWhite ?? this.pureWhite,
      foodHomeAppBar: mainBgPath ?? foodHomeAppBar,
      divider: divider ?? this.divider,
    );
  }
}
