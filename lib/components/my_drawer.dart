import 'package:flutter/material.dart';
import 'package:twitter_clone/components/my_drawer_tile.dart';
import 'package:twitter_clone/pages/profile_page.dart';
import 'package:twitter_clone/pages/search_page.dart';
import 'package:twitter_clone/pages/settings_page.dart';
import 'package:twitter_clone/services/auth/auth_service.dart';
/*
Drawer

This is a menu drawer which is usually acess on the left side of the app bar. It is used to navigate to different pages of the app.

 */

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  //access to the authentication service

  final _auth = AuthService();

  //logout function
  void logout() {
    _auth.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              //app logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              //divider line
              Divider(color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 10),

              //home list tile
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              //profile list tile
              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: () {
                  //pop menu drawer
                  Navigator.pop(context);

                  //go to the profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProfilePage(uid: _auth.getCurrentUserid()),
                    ),
                  );
                },
              ),

              //search list tile
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: () {
                  //pop menu drawer
                  Navigator.pop(context);

                  //go to the search page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
              ),

              //settings tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),

              const Spacer(),

              //logout tile
              MyDrawerTile(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: logout,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
