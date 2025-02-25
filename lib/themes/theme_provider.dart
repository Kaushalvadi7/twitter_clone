import 'package:flutter/material.dart';
import 'package:twitter_clone/themes/dark_mode.dart';
import 'package:twitter_clone/themes/light_mode.dart';

/*
Theme Provider
This class is responsible for managing the theme of the app.
It extends ChangeNotifier so that it can notify its listeners when the theme changes.
 */
class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
