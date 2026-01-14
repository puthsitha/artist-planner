import 'package:artistplanner/core/themes/themes.dart';
import 'package:flutter/material.dart';

const bodyPadding = EdgeInsets.all(Spacing.normal);
const paddingHorizontal = EdgeInsets.symmetric(horizontal: Spacing.normal);
const paddingVertical = EdgeInsets.symmetric(vertical: Spacing.normal);

/// The standard body padding for the app.
const kBodyPadding = EdgeInsets.symmetric(horizontal: Spacing.l);
const kPadding = EdgeInsets.all(Spacing.l);

/// The standard button padding for the app.
const kButtonPadding = EdgeInsets.symmetric(
  vertical: Spacing.sm,
  horizontal: Spacing.normal,
);

/// The standard app bar button size.
const double kAppBarButtonSize = 56;

final ShapeBorder kCardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(Raduis.normal),
);

final BorderRadius kBorderRadius = BorderRadius.circular(Raduis.l);

/// The standard shadow for containers
const kCardShadow = [
  BoxShadow(
    blurRadius: 6,
    color: Color.fromRGBO(153, 153, 153, 0.46),
    offset: Offset(0, 2),
    spreadRadius: 0.2,
  ),
];

/// The standard shadow for containers
const kAppBarShadow = [
  BoxShadow(
    blurRadius: 9,
    color: Color.fromRGBO(153, 153, 153, 0.3),
    offset: Offset(0, 1),
    spreadRadius: 3,
  ),
];

/// The secondary shadow for containers with primaryColor
const kCardShadowPrimary = [
  BoxShadow(
    blurRadius: 32.2,
    color: Color.fromRGBO(55, 1, 120, 0.59),
    offset: Offset(0, 5),
    spreadRadius: 2.8,
  ),
];

/// The secondary shadow for buttons
const kButtonShadow = [
  BoxShadow(
    blurRadius: 9.2,
    color: Color.fromRGBO(153, 153, 153, 0.5),
    offset: Offset(0, 4),
  ),
];

/// button navigation bar height
const double kBottomNavBarHeight = 72;
