import 'package:flutter/material.dart';
import 'app_color_schemes.dart';
import 'app_shapes.dart';
import 'app_text_styles.dart';

/// The overall app theme. We define [ThemeData] here using our color schemes,
/// typography, shapes, etc.
class AppTheme {
  // Dark Theme using our color scheme, typography, shapes, etc.
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: darkColorScheme, // from app_color_schemes.dart
    useMaterial3: true,           // Enable Material 3
    // Define overall visual density if you want a more compact look:
    visualDensity: VisualDensity.compact, 
    textTheme: AppTextStyles.textTheme,
    // or combine with the default M3 text theme:
    // textTheme: Typography.material2021().white.merge(AppTextStyles.textTheme),

    // SHAPE
    cardTheme: CardTheme(
      shape: AppShapes.cardShape, 
      margin: EdgeInsets.zero,
    ),
    dialogTheme: DialogTheme(
      shape: AppShapes.dialogShape,
    ),
    
    // BUTTON THEMES
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(AppShapes.buttonShape),
        // For color, rely on colorScheme. E.g.:
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return darkColorScheme.onSurface.withOpacity(0.12);
          }
          return darkColorScheme.primary; // Purple by default
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return darkColorScheme.onSurface.withOpacity(0.38);
          }
          return darkColorScheme.onPrimary; // Typically white or near-white
        }),
        // Padding for a compact button
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(AppShapes.buttonShape),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: darkColorScheme.onSurface.withOpacity(0.12),
            );
          }
          return BorderSide(color: darkColorScheme.primary);
        }),
        // same approach to padding, text color, etc.
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(AppShapes.buttonShape),
        foregroundColor: WidgetStateProperty.all(darkColorScheme.primary),
      ),
    ),

    // INPUT THEME
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkColorScheme.surfaceContainerHighest, 
      // or some other color that stands out slightly from background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.smallRadius),
        borderSide: BorderSide.none, // If you prefer no border by default
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.smallRadius),
        borderSide: BorderSide(
          color: darkColorScheme.primary,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      hintStyle: TextStyle(
        color: darkColorScheme.onSurface.withOpacity(0.6), 
      ),
      labelStyle: TextStyle(
        color: darkColorScheme.onSurface.withOpacity(0.9),
      ),
    ),

    // CARD THEME
    // Already set shape in cardTheme, optionally define color if needed
    cardColor: darkColorScheme.surface, 

    // FloatingActionButton, Checkbox, Switch, etc. can be themed similarly.

    // SCROLLBAR, DIVIDER, Etc.
    dividerTheme: const DividerThemeData(thickness: 1),
  );
}
