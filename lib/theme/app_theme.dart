import 'package:flutter/material.dart';
import 'app_color_schemes.dart';   // Where you define AppColorScheme.darkColorSchemeHSL
import 'app_shapes.dart';        // Where AppShapes is defined
import 'app_text_styles.dart';   // Where AppTextStyles is defined'

/// The overall app theme using our custom HSL-based dark color scheme,
/// typography, shapes, etc.
class AppTheme {
  // Dark Theme with our custom HSL-based color scheme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true, // Enable Material 3

    // Tie to our custom HSL-based color scheme:
    colorScheme: AppColorScheme.darkColorSchemeHSL,

    // Define overall visual density for a more compact look:
    visualDensity: VisualDensity.compact,

    // Typography: we reference the textTheme we created
    textTheme: AppTextStyles.textTheme,
    // Or combine with default M3 text theme:
    // textTheme: Typography.material2021().white.merge(AppTextStyles.textTheme),

    // Define a different scaffold background color than the card color
    scaffoldBackgroundColor: AppColorScheme.darkColorSchemeHSL.background,
    

    //--------------------------------------------------------------------
    // SHAPES
    //--------------------------------------------------------------------
    cardTheme: CardTheme(
      shape: AppShapes.cardShape,
      margin: EdgeInsets.zero,
      color: AppColorScheme.darkColorSchemeHSL.surface,
      // color: optionally override the card background color:
      // color: AppColorScheme.darkColorSchemeHSL.surface,
    ),
    dialogTheme: DialogTheme(
      shape: AppShapes.dialogShape,
      // color: optional custom background for dialogs
    ),

    //--------------------------------------------------------------------
    // BUTTON THEMES (Elevated, Outlined, Text)
    //--------------------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(AppShapes.buttonShape),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColorScheme.darkColorSchemeHSL.onSurface.withOpacity(0.12);
          }
          return AppColorScheme.darkColorSchemeHSL.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColorScheme.darkColorSchemeHSL.onSurface.withOpacity(0.38);
          }
          return AppColorScheme.darkColorSchemeHSL.onPrimary;
        }),
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
              color: AppColorScheme.darkColorSchemeHSL.onSurface.withOpacity(0.12),
            );
          }
          return BorderSide(
            color: AppColorScheme.darkColorSchemeHSL.primary,
          );
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(AppShapes.buttonShape),
        foregroundColor: WidgetStateProperty.all(
          AppColorScheme.darkColorSchemeHSL.primary,
        ),
      ),
    ),

    //--------------------------------------------------------------------
    // INPUT THEME
    //--------------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      // If your colorScheme lacks surfaceVariant, pick a suitable fallback:
      fillColor: AppColorScheme.darkColorSchemeHSL.surface, // or .surfaceVariant
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.smallRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppShapes.smallRadius),
        borderSide: BorderSide(
          color: AppColorScheme.darkColorSchemeHSL.primary,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(
        color: AppColorScheme.darkColorSchemeHSL.onSurface.withOpacity(0.6),
      ),
      labelStyle: TextStyle(
        color: AppColorScheme.darkColorSchemeHSL.onSurface.withOpacity(0.9),
      ),
    ),

    //--------------------------------------------------------------------
    // CARD THEME
    //--------------------------------------------------------------------
    cardColor: AppColorScheme.darkColorSchemeHSL.surface,

    // Example: scrollbar, divider:
    dividerTheme: const DividerThemeData(thickness: 1),
  );
}
