import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_user_tile.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  //text controller
  final _searchController = TextEditingController();

  //Build UI
  @override
  Widget build(BuildContext context) {
    //provider
    final databaseProvider = Provider.of<DatabaseProvider>(
      context,
      listen: false,
    );
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    //Scaffold
    return Scaffold(
      //appbar
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search users..",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            border: InputBorder.none,
          ),

          //search will bigin after each new character has been type
          onChanged: (value) {
            //search for users
            if (value.isNotEmpty) {
              databaseProvider.searchUsers(value);
            }
            //clear results
            else {
              databaseProvider.searchUsers("");
            }
          },
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,

      //body
      body:
          listeningProvider.searchResults.isEmpty
              ?
              //no user found..
              Center(child: Text("No users found.."))
              :
              //user found!
              ListView.builder(
                itemCount: listeningProvider.searchResults.length,
                itemBuilder: (context, index) {
                  //get each user from search result
                  final User = listeningProvider.searchResults[index];

                  //return as a user tile
                  return MyUserTile(user: User);
                },
              ),
    );
  }
}
