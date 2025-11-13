import 'package:flutter/material.dart';

import 'widget_themes/appbar_theme.dart';
import 'widget_themes/elevated_button_theme.dart';
import 'widget_themes/outlined_button_theme.dart';
import 'widget_themes/text_field_theme.dart';
import 'widget_themes/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF5B7FDB), // Blue for light mode
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF5B7FDB), // Blue for light mode
      onPrimary: Color(0xFFFFFFFF), // White text on primary
      secondary: Color(0xFF272727), // Dark Gray
      onSecondary: Color(0xFFFFFFFF), // White text on secondary
      surface: Color(0xFFFFFFFF), // White surface
      onSurface: Color(0xFF222A3D), // Nightingale Gray 80 text on surface
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF), // White text on error
    ),
    cardColor: Colors.white, // Pure white cards for light mode
    dividerColor: const Color(0xFFD1D5DB),
    textTheme: TTextTheme.lightTextTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFFFE400), // Bright Yellow
    scaffoldBackgroundColor: const Color(0xFF02040A), // Very dark background
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFE400), // Bright Yellow
      onPrimary: Color(0xFF272727), // Dark Gray text on primary
      secondary: Color(0xFF272727), // Dark Gray
      onSecondary: Color(0xFFFFFFFF), // White text on secondary
      surface: Color(0xFF13192B), // Dark Blue-Gray surface
      onSurface: Color(0xFFFFFFFF), // White text on surface
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF), // White text on error
    ),
    cardColor: const Color(0xFF13192B),
    dividerColor: const Color(0xFF9CA3AF),
    textTheme: TTextTheme.darkTextTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  );
}
