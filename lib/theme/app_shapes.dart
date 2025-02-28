import 'package:flutter/material.dart';

/// Defines the application shape: semi-rounded corners
/// This is used in multiple places (cards, dialogs, buttons, etc.).
class AppShapes {
  static const double smallRadius = 8.0;  // For smaller components
  static const double mediumRadius = 12.0; // For bigger surfaces
  
  // If you want everything consistently:
  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(smallRadius),
  );

  static final RoundedRectangleBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(mediumRadius),
  );

  // For theming different shaped components:
  static final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(smallRadius),
  );
}
