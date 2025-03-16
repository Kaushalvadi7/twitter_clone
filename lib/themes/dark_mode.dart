import 'package:flutter/material.dart';

 ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(

    surface: const Color(0xFF000000), // Pure black background
    primary: const Color(0xFFFFFFFF), // Clean white for icons and text
    secondary: const Color(0xFF272727), // Dark grey for cards/containers
    tertiary: const Color(0xFF3A3A3A), // Slightly lighter grey for highlights
    inversePrimary: Colors.white, // Blue accent for links or highlights


    // surface: const Color.fromARGB(255, 20, 20, 20),
    // primary: const Color.fromARGB(255, 105, 105, 105),
    // secondary: const Color.fromARGB(255, 30, 30, 30),
    // tertiary: const Color.fromARGB(255, 47, 47, 47),
    // inversePrimary: Colors.grey.shade300,
  ),
);
