import 'package:flutter/material.dart';

final ThemeData orangeTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFFFF6B00), // Main orange
  scaffoldBackgroundColor: Color(0xFFF5F5F5), // Light background
  cardColor: Colors.white, // Surface/Card
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFFF6B00),
    foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFFF6B00), // Main orange
    onPrimary: Colors.white,
    secondary: Color(0xFFFFA552), // Light orange
    onSecondary: Colors.white,
    error: Color(0xFFEA5455), // Red for errors
    onError: Colors.white,
    background: Color(0xFFF5F5F5),
    onBackground: Color(0xFF1F1F1F),
    surface: Colors.white,
    onSurface: Color(0xFF1F1F1F),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(color: Color(0xFF1F1F1F), fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Color(0xFF1F1F1F)),
    bodyMedium: TextStyle(color: Color(0xFF6E6E6E)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFF6B00),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFF6B00),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFF6B00), width: 2),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFFFF6B00),
    contentTextStyle: TextStyle(color: Colors.white),
  ),
);
