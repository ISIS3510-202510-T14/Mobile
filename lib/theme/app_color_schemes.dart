import 'package:flutter/material.dart';

/// Defines the core dark color scheme using a purple seed color.
/// In Material 3, you can generate a full color scheme by seeding from a single color
/// using [ColorScheme.fromSeed].
final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Colors.deepPurple, // or your preferred purple hue
);

// Example of manually defining a dark color scheme
final ColorScheme darkColorSchemeCustom = const ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFB39DDB), // a light purple for dark backgrounds
  onPrimary: Colors.black,
  secondary: Color(0xFFE0BBE4), // accent color
  onSecondary: Colors.black,
  error: Color(0xFFF2B8B5),
  onError: Colors.black,
  background: Color(0xFF121212),
  onBackground: Color(0xFFE1E1E1),
  surface: Color(0xFF1D1D1D),
  onSurface: Color(0xFFE1E1E1),
);

