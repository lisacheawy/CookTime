import 'package:flutter/material.dart';
import 'constants.dart';

ThemeData buildThemeData() {
  return ThemeData(
    scaffoldBackgroundColor: kBackgroundColor,
    primaryColor: kPrimaryColor,
    fontFamily: 'Poppins',
    textTheme: TextTheme(
        headlineMedium: TextStyle(
            fontSize: 30, fontWeight: FontWeight.w600, color: kTextColor),
        headlineSmall:
            TextStyle(fontWeight: FontWeight.w600, color: kTextColor),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: kTextColor),
        titleSmall: TextStyle(fontWeight: FontWeight.w500, color: kTextColor),
        bodyLarge: TextStyle(color: kTextColor),
        bodyMedium: TextStyle(color: kTextColor),
        bodySmall: TextStyle(color: kSecondaryColor)),

    // inputDecorationTheme: inputDecorationTheme,
    // buttonTheme: buttonThemeData,
    // visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
