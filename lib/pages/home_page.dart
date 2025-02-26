import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_drawer.dart';
import 'package:twitter_clone/components/my_input_alert_box.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/helper/navigate_pages.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //text controllers
  final _messageController = TextEditingController();

  //on startup,
  @override
  void initState() {
    super.initState();

    //let's load all the posts!
    loadAllPosts();
  }

  //load all posts
  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  //show post message dailog box
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder:
          (context) => MyInputAlertBox(
            textController: _messageController,
            hintText: "What's on your mind?",
            onPressed: () async {
              //post in db
              await postMessage(_messageController.text);
            },
            onPressedText: "Post",
          ),
    );
  }

  //user wants to post message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    //Scaffold
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),

      //APP BAR
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "H O M E",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessageBox,
        child: const Icon(Icons.add),
      ),

      //body list of all posts
      body: _buildPostList(listeningProvider.allPosts),
    );
  }

  //build list ui given a list of posts
  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ?
        //post list is empty
        const Center(child: Text("Nothing here..."))
        //post list is Not Empty
        : ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            //get each individual post
            final post = posts[index];

            //return Post Tile UI
            return MyPostTile(post: post, 
            onUserTap: () => goUserPage(context, post.uid));
          },
        );
  }
}
