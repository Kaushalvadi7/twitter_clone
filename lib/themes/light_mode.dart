import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(

    surface: Colors.white,            // Clean white background
    primary: Colors.black,            // Dark text/icons for contrast
    secondary: const Color(0xFFE6E6E6), // Light grey for cards/containers
    tertiary: const Color(0xFFF0F0F0), // Soft grey highlights
    inversePrimary: Colors.black, // Blue accent for links or highlight

    // surface: Colors.grey.shade300,
    // primary: Colors.grey.shade500,
    // secondary: Colors.grey.shade200,
    // tertiary: Colors.white,
    // inversePrimary: Colors.grey.shade900,
  ),
);
