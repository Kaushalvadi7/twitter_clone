import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/components/my_comment_tile.dart';
import 'package:twitter_clone/components/my_post_tile.dart';
import 'package:twitter_clone/helper/navigate_pages.dart';
import 'package:twitter_clone/models/post.dart';

import '../services/database/database_provider.dart';

class PostPage extends StatefulWidget {
  final Post post;

  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  //provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider = Provider.of<DatabaseProvider>(
    context,
    listen: false,
  );
  
  //build ui
  @override
  Widget build(BuildContext context) {
    //listen to all comments for this post
    final allComments = listeningProvider.getComments(widget.post.id);
    
    //SCAFFOLD
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //APP BAR
      appBar: AppBar(foregroundColor: Theme.of(context).colorScheme.primary),

      //body
      body: ListView(
        children: [
          //post
          MyPostTile(
            post: widget.post,
            onUserTap: () => goUserPage(context, widget.post.uid),
            onPostTap: () {},
          ),
          
          //Comments on this post
          allComments.isEmpty? 
              
          //no comments yet..
          Center(child: Text("No comments yet.."),):
              
          // comments exist
          ListView.builder(
          itemCount: allComments.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context,index) {
            //get each comment
        final comment = allComments[index];

        //return as comment tile UI
            return  MyCommentTile(comment: comment,
              onUserTap: () => goUserPage(context, comment.uid),);
    },
          )
        ],
      ),
    );
  }
}
