import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_settings_tile.dart';
import 'package:twitter_clone/themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //app bar
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "S E T T I N G S",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //body
      body: Column(
        children: [
          //dark mode tile
          MySettingsTile(
            title: "Dark Mode",
            action: CupertinoSwitch(
              value:
                  Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
              onChanged:
                  (value) =>
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).toggleTheme(),
            ),
          ),

          //block users tile

          //Accounts settings tile
        ],
      ),
    );
  }
}
