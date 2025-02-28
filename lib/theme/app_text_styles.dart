import 'package:flutter/material.dart';

/// Defines a small, coherent set of text styles for the app.
/// In Material 3, we can assign these to the TextTheme.
class AppTextStyles {
  // Example base font size choices:
  // - Large Title: 20sp
  // - Medium Title: 16sp
  // - Body: 14sp
  // - Small/Caption: 12sp

  static const TextStyle displayLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    // letterSpacing, color, etc. can be set, but color is typically from the theme.
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // You can add as many as needed, but keep them limited.
  
  /// Builds a [TextTheme] from these predefined styles.
  static TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    titleMedium: titleMedium,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    // etc.
  );
}
