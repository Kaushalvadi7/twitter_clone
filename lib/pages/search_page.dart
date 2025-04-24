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
  final FocusNode _focusNode = FocusNode();

  //text controller
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

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
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Icon(Icons.search,size: 24,
          color: Theme.of(context).colorScheme.inversePrimary,),
        ),
        titleSpacing: 1,
        title: TextField(
          focusNode: _focusNode,
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search users..",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize: 16),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear,color: Theme.of(context).colorScheme.inversePrimary,),
              onPressed: () {
                _searchController.clear();
                databaseProvider.searchUsers("");
                setState(() {}); // refresh to hide the icon
              },
            )
                : null,
          ),

          //search will begin after each new character has been type
          onChanged: (value) {
            //search for users
            if (value.isNotEmpty) {
              databaseProvider.searchUsers(value);
            }
            //clear results
            else {
              databaseProvider.searchUsers("");
            }
            setState(() {});
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
