import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'helper_functions.dart';

/// Helper class for text styling and visibility across light and dark modes
class TTextHelper {
  TTextHelper._();

  /// Get primary text color based on current theme
  static Color getPrimaryTextColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) 
        ? TColors.textDarkPrimary 
        : TColors.textPrimary;
  }

  /// Get secondary text color based on current theme
  static Color getSecondaryTextColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) 
        ? TColors.textDarkSecondary 
        : TColors.textSecondary;
  }

  /// Get icon color based on current theme
  static Color getIconColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) 
        ? TColors.iconPrimaryDark 
        : TColors.iconPrimaryLight;
  }

  /// Get secondary icon color based on current theme
  static Color getSecondaryIconColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) 
        ? TColors.iconSecondaryDark 
        : TColors.iconSecondaryLight;
  }

  /// Get border color based on current theme
  static Color getBorderColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) 
        ? TColors.borderDark 
        : TColors.borderLight;
  }

  /// Get disabled text color based on current theme
  static Color getDisabledTextColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) 
        ? TColors.disabledTextDark 
        : TColors.disabledTextLight;
  }

  /// Get container/card background color based on current theme
  static Color getContainerColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) 
        ? TColors.darkContainer 
        : TColors.lightContainer;
  }

  /// Get card background color based on current theme
  static Color getCardColor(BuildContext context) {
    return THelperFunctions.isDarkMode(context) 
        ? TColors.darkContainer 
        : TColors.cardBackgroundColor;
  }

  /// Get adaptive text style with automatic color adjustment
  static TextStyle getAdaptiveTextStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    bool isSecondary = false,
  }) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium!;
    return baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isSecondary 
          ? getSecondaryTextColor(context) 
          : getPrimaryTextColor(context),
    );
  }

  /// Create a Text widget with adaptive colors
  static Text adaptiveText(
    String text,
    BuildContext context, {
    TextStyle? style,
    bool isSecondary = false,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    final color = isSecondary 
        ? getSecondaryTextColor(context) 
        : getPrimaryTextColor(context);
    
    return Text(
      text,
      style: style?.copyWith(color: color) ?? TextStyle(color: color),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
