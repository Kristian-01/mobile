import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/colors.dart';

/* -- Light & Dark Text Themes -- */
class TTextTheme {
  TTextTheme._(); //To avoid creating instances

  /* -- Light Text Theme -- */
  static TextTheme lightTextTheme = TextTheme(
    // Headings - Large titles
    displayLarge: GoogleFonts.poppins(fontSize: 28.0, fontWeight: FontWeight.bold, color: TColors.textPrimary),
    displayMedium: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.w700, color: TColors.textPrimary),
    displaySmall: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    
    // Headings - Medium titles
    headlineLarge: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    headlineMedium: GoogleFonts.poppins(fontSize: 18.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    headlineSmall: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    
    // Titles - Smaller headings
    titleLarge: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    titleMedium: GoogleFonts.poppins(fontSize: 14.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    titleSmall: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.w600, color: TColors.textPrimary),
    
    // Body text - Regular content
    bodyLarge: GoogleFonts.poppins(fontSize: 14.0, fontWeight: FontWeight.normal, color: TColors.textPrimary),
    bodyMedium: GoogleFonts.poppins(fontSize: 13.0, fontWeight: FontWeight.normal, color: TColors.textSecondary),
    bodySmall: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.normal, color: TColors.textSecondary),
    
    // Labels - Small text
    labelLarge: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.w500, color: TColors.textPrimary),
    labelMedium: GoogleFonts.poppins(fontSize: 11.0, fontWeight: FontWeight.w500, color: TColors.textSecondary),
    labelSmall: GoogleFonts.poppins(fontSize: 10.0, fontWeight: FontWeight.w500, color: TColors.textSecondary),
  );

  /* -- Dark Text Theme -- */
  static TextTheme darkTextTheme = TextTheme(
    // Headings - Large titles
    displayLarge: GoogleFonts.poppins(fontSize: 28.0, fontWeight: FontWeight.bold, color: TColors.textDarkPrimary),
    displayMedium: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.w700, color: TColors.textDarkPrimary),
    displaySmall: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w600, color: TColors.textDarkPrimary),
    
    // Headings - Medium titles
    headlineLarge: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w600, color: TColors.textDarkPrimary),
    headlineMedium: GoogleFonts.poppins(fontSize: 18.0, fontWeight: FontWeight.w600, color: TColors.textDarkPrimary),
    headlineSmall: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: TColors.textDarkPrimary),
    
    // Titles - Smaller headings
    titleLarge: GoogleFonts.poppins(fontSize: 16.0, fontWeight: FontWeight.w600, color: TColors.textDarkPrimary),
    titleMedium: GoogleFonts.poppins(fontSize: 14.0, fontWeight: FontWeight.w600, color: TColors.textDarkPrimary),
    titleSmall: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.w600, color: TColors.textDarkPrimary),
    
    // Body text - Regular content
    bodyLarge: GoogleFonts.poppins(fontSize: 14.0, fontWeight: FontWeight.normal, color: TColors.textDarkPrimary),
    bodyMedium: GoogleFonts.poppins(fontSize: 13.0, fontWeight: FontWeight.normal, color: TColors.textDarkSecondary),
    bodySmall: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.normal, color: TColors.textDarkSecondary),
    
    // Labels - Small text
    labelLarge: GoogleFonts.poppins(fontSize: 12.0, fontWeight: FontWeight.w500, color: TColors.textDarkPrimary),
    labelMedium: GoogleFonts.poppins(fontSize: 11.0, fontWeight: FontWeight.w500, color: TColors.textDarkSecondary),
    labelSmall: GoogleFonts.poppins(fontSize: 10.0, fontWeight: FontWeight.w500, color: TColors.textDarkSecondary),
  );
}
