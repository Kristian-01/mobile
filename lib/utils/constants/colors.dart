import 'package:flutter/material.dart';

class TColors {
  // App theme colors - Yellow & Blue Palette
  static const Color primary = Color(0xFFFFC107); // Softer Yellow (Amber)
  static const Color secondary = Color(0xFF1E1E1E); // Softer Dark Gray
  static const Color secondaryLight = Color(0xFF346DAE); // Blue with transparency
  static const Color primaryBackground = Color(0xFFCCFBF1); // Light Teal
  static const Color secondaryBackground = Color(0xFFFFE4E6); // Light Pink
  static const Color accent = Color(0xFF001BFF); // Blue

  // Dashboard Specific Colors - Light Mode uses Blue Gradient
  static const Color dashboardAppbarBackgroundLight = Color(0xFF5B7FDB); // Blue for light mode
  static const Color dashboardAppbarBackgroundLight2 = Color(0xFF4A6FA5); // Gradient end blue
  static const Color dashboardAppbarBackground = Color(0xFF272727); // Dark Gray for dark mode

  // Text colors
  static const Color textPrimary = Color(0xFF222A3D); // Nightingale Gray 80 (Light mode primary text)
  static const Color textSecondary = Color(0xFF4B5363); // Nightingale Gray 60 (Light mode secondary text)
  static const Color textDarkPrimary = Color(0xFFFFFFFF); // White (Dark mode primary text)
  static const Color textDarkSecondary = Color(0xFFD1D5DB); // Light Gray (Dark mode secondary text)
  static const Color textWhite = Colors.white;

  static const Color disabledTextLight = Color(0xFFD1D5DB); // Light Gray (Light mode disabled text)
  static const Color disabledBackgroundLight = Color(0xFFF3F4F6); // Light Gray (Light mode disabled background)

  static const Color disabledTextDark = Color(0xFF4B5363); // Gray (Dark mode disabled text)
  static const Color disabledBackgroundDark = Color(0xFF222A3D); // Nightingale Gray 80 (Dark mode disabled background)

  // Background colors
  static const Color lightBackground = Color(0xFFFFFFFF); // White (Light mode main background)
  static const Color darkBackground = Color(0xFF121212); // Softer Dark Background (Dark mode main background)

  // Background Container colors
  static const Color lightContainer = Color(0xFFF3F4F6); // Light Gray (Light mode container)
  static const Color darkContainer = Color(0xFF13192B); // Dark Blue-Gray (Dark mode container)
  static const Color cardBackgroundColor = Color(0xFFF7F5F1); // Off-white/Cream (Card background)

  // Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = disabledBackgroundLight;

  // -- Social Button Colors
  static const Color googleBackgroundColor = Color(0xFFDFEFFF);
  static const Color googleForegroundColor = Color(0xFF167EE6);
  static const Color facebookBackgroundColor = Color(0xFF1877F2);

  // -- ON-BOARDING COLORS
  static const Color onBoardingPage1Color = Colors.white;
  static const Color onBoardingPage2Color = Color(0xfffddcdf);
  static const Color onBoardingPage3Color = Color(0xffffdcbd);

  // Icon colors
  static const Color iconPrimaryLight = Color(0xFF5B7FDB); // Blue (Light mode primary icons - matches header)
  static const Color iconSecondaryLight = Color(0xFF9CA3AF); // Gray (Light mode secondary icons)
  static const Color iconPrimaryDark = Color(0xFFFFFFFF); // White (Dark mode primary icons)
  static const Color iconSecondaryDark = Color(0xFF9CA3AF); // Gray (Dark mode secondary icons)

  // Border colors
  static const Color borderPrimary = primary;
  static const Color borderSecondary = secondary;
  static const Color borderLight = Color(0xFFD1D5DB); // Light Gray (Light mode border)
  static const Color borderDark = Color(0xFF9CA3AF); // Medium Gray (Dark mode border)

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF1A1A1A);
  static const Color teal90 = Color(0xFF004D40);
  static const Color teal80 = Color(0xFF00695C);
  static const Color teal20 = Color(0xFF99F6E4);
  static const Color dark = Color(0xFF1E1E1E);
  static const Color darkerGrey = Color(0xFF2A2A2A);
  static const Color darkGrey = Color(0xFF757575);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color grey10 = Color(0xFFF3F4F6);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color light = Color(0xFFF6F6F6);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xfff43F5E);
}
