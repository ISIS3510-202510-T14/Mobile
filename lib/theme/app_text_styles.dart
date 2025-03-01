import 'package:flutter/material.dart';

/// A revamped text style set applying the principles from:
/// 1) A well-defined type scale (36/24/16/12 px)
/// 2) Minimal, readable line-heights
/// 3) Simple font-weight variations (400/600/700)
/// 4) No 'em' units or fractional scales
/// 5) Trust the font's built-in letter spacing
///
/// See Section #4: "Designing Text" for detailed rationale:
/// - Keep your scale flexible but avoid overusing too many font sizes.
/// - Provide enough line-height for readability (especially for smaller text).
/// - Avoid centering long text; rely on baseline alignment in actual widgets.
/// - Use good, legible fonts (e.g., system fonts or high-quality families).
class AppTextStyles {
  /// For the largest, prominent headings (think big hero text or top-level headers).
  /// - 36px is a common “display” or “headline” size in a hierarchy.
  /// - A bolder weight (700) helps it stand out.
  /// - A slightly tighter line-height (1.2) because large text needs less spacing.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2, 
  );

  /// For mid-level headings or subheadings.
  /// - 24px remains comfortable for short titles.
  /// - Weight 600 (semi-bold) to distinguish it from normal body text.
  /// - 1.3 line-height for a balanced look.
  static const TextStyle titleMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// The main body text style for paragraphs and standard content.
  /// - 16px is commonly considered an ideal "base" for comfortable reading.
  /// - Normal weight (400) for body text.
  /// - 1.5 line-height to ensure clarity on multiple lines.
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Smaller text for secondary or tertiary information (captions, notes, disclaimers).
  /// - 12px is legible but clearly “small."
  /// - Still normal weight (400); consider 1.5 line-height to keep it readable.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Combine our custom styles into a TextTheme.
  /// We do not set color or letterSpacing here:
  /// - Let color be inherited from the Material theme’s `colorScheme`.
  /// - Rely on the typeface’s default letter spacing to avoid complicating readability.
  static TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    titleMedium: titleMedium,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );
}
