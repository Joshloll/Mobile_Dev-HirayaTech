import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- YOUR BRAND'S COLOR PALETTE ---
const Color hirayaBlue = Color(0xFF0B2545);
const Color hirayaGold = Color(0xFFFDB813);

// --- THE GLOBAL THEME DATA ---
final ThemeData appTheme = ThemeData(
  primaryColor: hirayaBlue,
  scaffoldBackgroundColor: Colors.white,

  colorScheme: ColorScheme.fromSeed(
    seedColor: hirayaBlue,
    primary: hirayaBlue,
    secondary: hirayaGold,
    brightness: Brightness.light,
  ),

  textTheme: GoogleFonts.splineSansTextTheme(
    ThemeData.light().textTheme,
  ).apply(
    bodyColor: hirayaBlue,
    displayColor: hirayaBlue,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: hirayaBlue,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.splineSans(
      color: hirayaBlue,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: hirayaBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: GoogleFonts.splineSans(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: hirayaBlue,
      textStyle: GoogleFonts.splineSans(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: hirayaBlue,
    foregroundColor: Colors.white,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: hirayaBlue,
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    hintStyle: TextStyle(color: Colors.grey.shade500),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: hirayaBlue, width: 2),
    ),
  ),

  chipTheme: ChipThemeData(
    selectedColor: hirayaBlue, // Filters are blue
    checkmarkColor: Colors.white,
    labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    backgroundColor: Colors.grey.shade100,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: BorderSide.none,
  ),

  tabBarTheme: TabBarThemeData(
    indicatorColor: hirayaGold, // Tab indicator is gold
    labelColor: hirayaBlue,
    unselectedLabelColor: Colors.grey,
    labelStyle: TextStyle(fontWeight: FontWeight.bold),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: hirayaGold, // Progress bars are gold
    linearTrackColor: Color(0xFFE0E0E0),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return hirayaBlue; // Switches use primary blue
      }
      return Colors.grey.shade400;
    }),
    trackColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return hirayaBlue.withOpacity(0.5);
      }
      return Colors.grey.shade200;
    }),
  ),
);