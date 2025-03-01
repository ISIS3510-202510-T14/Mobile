import 'package:flutter/material.dart';

/// A helper to define colors in HSL more conveniently.
/// We use [HSLColor.fromAHSL] (alpha, hue, saturation, lightness).
/// All parameters are from 0..1 except hue which is 0..360. For instance:
///   alpha = 1.0 for fully opaque,
///   hue in degrees [0..360],
///   saturation in [0..1],
///   lightness in [0..1].
///
/// If you are used to percentages for saturation/lightness:
///   use e.g. 0.50 for 50% saturation, 0.90 for 90% saturation, etc.
Color hsl(double hue, double saturation, double lightness, [double alpha = 1.0]) {
  return HSLColor.fromAHSL(alpha, hue, saturation, lightness).toColor();
}

///--------------------------------------------------------------------
/// GREY SCALE (DARK THEME ORIENTED) 
/// 
/// Based on the theory “Greys don’t have to be grey,” we’ll use a slightly
/// warm grey (small hue around 30°, low saturation) so it doesn’t feel cold.
/// We define multiple steps from darkest (suitable for text on dark surfaces) 
/// up to a near-white tint for backgrounds.
///--------------------------------------------------------------------
class AppGreys {
  // Hue ~ 30°, Saturation ~ 0.06 -> a subtle warm cast 
  // (feel free to tweak these for your brand personality)
  //
  // We'll create a scale from l=0.08 (dark) up to l=0.95 (very light).
  // 
  // The naming 900,800,...100 is reminiscent of Material, but we define them in HSL.  

  static final Color grey900 = hsl(30, 0.06, 0.08); // darkest
  static final Color grey800 = hsl(30, 0.06, 0.12);
  static final Color grey700 = hsl(30, 0.06, 0.16);
  static final Color grey600 = hsl(30, 0.06, 0.24);
  static final Color grey500 = hsl(30, 0.06, 0.32);
  static final Color grey400 = hsl(30, 0.06, 0.50);
  static final Color grey300 = hsl(30, 0.06, 0.70);
  static final Color grey200 = hsl(30, 0.06, 0.85);
  static final Color grey100 = hsl(30, 0.06, 0.95); // lightest
}

///--------------------------------------------------------------------
/// PURPLE PRIMARY (DARK THEME)
///
/// We'll define a purple scale. Let’s pick a base hue ~ 270° (a common choice
/// for purples) and vary saturation and lightness across multiple steps.
/// 
/// Theory Tips:
///  - The “base/mid” is typically around 50% lightness if we want it vibrant. 
///  - For darkest shades, reduce lightness significantly, maybe also rotate the hue
///    slightly toward 240° if you want to keep the purple from going too muddy.
///  - For very light tints, we keep the hue ~270° but raise lightness near 90%, 
///    possibly also raising saturation so it doesn't get too washed out. 
///--------------------------------------------------------------------
class AppPurples {
  // We'll define 9 steps [100..900] around hue=270°, adjusting saturation/lightness
  // to ensure each step looks visually distinct. 
  // You can further tweak the hue +/- a few degrees for dark or light edges.

  // Lightest
  static final Color purple100 = hsl(270, 0.60, 0.90);
  static final Color purple200 = hsl(270, 0.65, 0.80);
  static final Color purple300 = hsl(270, 0.65, 0.70);
  static final Color purple400 = hsl(270, 0.70, 0.60);

  // Base ~ 50% lightness
  static final Color purple500 = hsl(270, 0.80, 0.50);

  // Darker
  static final Color purple600 = hsl(268, 0.85, 0.40);
  static final Color purple700 = hsl(266, 0.90, 0.33);
  static final Color purple800 = hsl(265, 0.95, 0.24);
  static final Color purple900 = hsl(264, 1.00, 0.16); 
}

///--------------------------------------------------------------------
/// ACCENT COLORS EXAMPLES
///
/// Let’s define a few accent colors in HSL for states like “error” or “success.” 
/// We'll also define a “warning” color. This ensures we can convey meaning
/// without relying on color alone—icons or shapes should complement them. 
///--------------------------------------------------------------------
class AppAccents {
  // Error Red: hue ~ 0°, up the saturation, vary the lightness
  static final Color errorLight = hsl(0, 0.80, 0.80);   // a light red
  static final Color error = hsl(0, 0.90, 0.50);        // base red
  static final Color errorDark = hsl(0, 0.95, 0.40);    // deeper red

  // Success Teal: hue ~ 180°, high saturation
  static final Color successLight = hsl(180, 0.55, 0.80); 
  static final Color success = hsl(180, 0.65, 0.45); 
  static final Color successDark = hsl(180, 0.70, 0.30); 

  // Warning Yellow/Orange: near hue=45..50 or so 
  // (pure yellow is hue=60, sometimes it’s too bright; we shift slightly)
  static final Color warningLight = hsl(50, 0.90, 0.80);
  static final Color warning = hsl(48, 0.95, 0.50);
  static final Color warningDark = hsl(46, 0.90, 0.35);
}

///--------------------------------------------------------------------
/// DARK COLOR SCHEME
///
/// We can build a custom ColorScheme by picking which shades from above
/// map to the Material colorScheme fields: [primary, onPrimary, secondary, etc.].
/// 
/// We’ll treat the darkest greys as surfaces and the light greys for slight 
/// layering. Our “primary” for brand usage is a middle-lighter purple to ensure 
/// decent contrast on a dark background (maybe purple300 or purple400). 
/// Then we define background, surface, error, etc. 
///--------------------------------------------------------------------
class AppColorScheme {
  /// If you want a minimal custom approach, define a single [ColorScheme].
  /// We'll assume a dark palette with purples as brand color, plus grey surfaces.
  /// 
  /// We can pick [purple500] as the primary for main brand usage,
  /// but note that on a dark background, that might be somewhat intense. 
  /// Alternatively, you might choose purple300 or purple400 for a calmer accent.
  static final ColorScheme darkColorSchemeHSL = ColorScheme(
    brightness: Brightness.dark,

    // Brand color:
    primary: AppPurples.purple400, 
    onPrimary: AppGreys.grey900, // text on that purple => we can choose black or a dark grey if we want contrast

    // Another accent color if we want it as "secondary":
    secondary: AppAccents.success, 
    onSecondary: AppGreys.grey900,

    // Background = very dark grey
    background: AppGreys.grey900,
    onBackground: AppGreys.grey100,

    // Surface = slightly lighter than background for cards
    surface: AppGreys.grey800,
    onSurface: AppGreys.grey100,

    // Error color from our accent reds:
    error: AppAccents.error,
    onError: AppGreys.grey900,

    // We can define these but they won’t always be used in Material 2 or 3:
    // (Material 3 uses tertiary, surfaceVariant, outline, etc.)
    tertiary: AppPurples.purple200, 
    onTertiary: AppGreys.grey900,

    // If you want to define shadow, outline, inverseSurface, etc., do so:
    // outline: ...
    // ...
  );
}
