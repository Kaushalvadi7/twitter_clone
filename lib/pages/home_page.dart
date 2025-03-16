import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_drawer.dart';
import 'package:twitter_clone/components/my_input_alert_box.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/helper/navigate_pages.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/pages/search_page.dart';
import 'package:twitter_clone/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Current Index for Bottom Navigation Bar
  int _selectedIndex = 0;

  // Pages for Bottom Navigation Bar
  final List<Widget> _pages = [
    const HomeContent(),
    const SearchPage(), // Create SearchPage widget separately
  ];

  //Handle Navigation Bar Tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF1DA1F2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

// Extracted HomeContent to manage original Home UI
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );

  //text controllers
  final _messageController = TextEditingController();

  //load all posts
  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  //show post message dialog box
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
  //on startup,
  @override
  void initState() {
    super.initState();

    //let's load all the posts!
    loadAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    //Tab controller: 2 tabs -> for you /following
    return DefaultTabController(
      length: 2,

      //Scaffold
      child: Scaffold(
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
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: const Color(0xFF1DA1F2),
            tabs: const [
              //Followers
              Tab(text: 'For you'),

              //Following
              Tab(text: 'Following'),
            ],
          ),
        ),

        //Floating Action Button
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF1DA1F2),
          onPressed: _openPostMessageBox,
          child: const Icon(Icons.add),
        ),

        //body list of all posts
        body: TabBarView(
          children: [
            //for you
            _buildPostList(listeningProvider.allPosts),

            //following
            _buildPostList(listeningProvider.followingPosts),
          ],
        ),
      ),
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
        return MyPostTile(
          post: post,
          onUserTap: () => goUserPage(context, post.uid),
          onPostTap: () => goPostPage(context, post),
        );
      },
    );
  }
}

