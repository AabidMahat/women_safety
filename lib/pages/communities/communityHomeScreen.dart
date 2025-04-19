import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/api/communityApi.dart';
import 'package:women_safety/api/postsApi.dart';
import 'package:women_safety/pages/posts/CreatePostPage.dart';
import 'package:women_safety/pages/posts/postDetailPage.dart';

class CommunityHomePage extends StatefulWidget {
  final Community community;
  const CommunityHomePage({super.key, required this.community});

  @override
  State<CommunityHomePage> createState() => _CommunityHomePageState();
}

class _CommunityHomePageState extends State<CommunityHomePage> {

  bool isJoined = false;
  CommunityApi communityApi = CommunityApi();
  bool joinButtonLoading  = false;
  List<Post> posts = [];
  int currentPage = 1;
  final int limit = 3;
  bool isLoadingPosts = false;
  bool hasMorePosts = true;
  final ScrollController _scrollController = ScrollController();
  final postsApi = PostApi();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isMember();
    fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Load more posts when 200 pixels close to bottom
        fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void isMember() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> joinedCommunities = prefs.getStringList("communities")?? [];
    print("joined communities: $joinedCommunities");
    setState(() {
      print("joined communities: $joinedCommunities");
      print("current community: ${widget.community.id}");
      isJoined = joinedCommunities.contains(widget.community.id);
    });

  }

  void toggleJoinStatus() async{
    bool toggle;

    setState(() {
      joinButtonLoading = true;
    });
    if(isJoined){
      toggle = await communityApi.leaveCommunity(widget.community.id);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> joinedCommunities = prefs.getStringList("communities")?? [];
      joinedCommunities.remove(widget.community.id);
      prefs.setStringList("communities", joinedCommunities);
    }
    else{
      toggle = await communityApi.joinCommunity(widget.community.id);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> joinedCommunities = prefs.getStringList("communities")?? [];
      joinedCommunities.add(widget.community.id);
      prefs.setStringList("communities", joinedCommunities);
    }

    setState(() {
      joinButtonLoading = false;

      if(toggle){
        isJoined = !isJoined;
      }
    });
  }

  void fetchPosts() async {
    if (isLoadingPosts || !hasMorePosts) return;

    setState(() {
      isLoadingPosts = true;
    });

    List<Post> newPosts = await postsApi.getCommunityPostsPaginated(currentPage, limit, widget.community.id);
    print("posts: $newPosts");

    setState(() {
      posts.addAll(newPosts);
      isLoadingPosts = false;
      if (newPosts.length < limit) {
        hasMorePosts = false;
      } else {
        currentPage++;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final community = widget.community;

    return Scaffold(
      appBar: AppBar(
        title: Text(community.name),
      ),
      body:ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        // Community Avatar
        CircleAvatar(
            radius: 50,
            backgroundImage: community.imageUrl == "default.png" ?
            NetworkImage("https://cdn.pixabay.com/photo/2020/06/06/19/23/lgbt-5267848_1280.png") as ImageProvider
                : NetworkImage(community.imageUrl) as ImageProvider
        ),
        const SizedBox(height: 12),

        // Name and Members Count
        Text(
          community.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('${community.memberCount} members'),

        const SizedBox(height: 16),

        // Join/Leave Button
        joinButtonLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: toggleJoinStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: isJoined ? Colors.grey : Colors.blue,
          ),
          child: Text(isJoined ? 'Leave' : 'Join'),
        ),

        const SizedBox(height: 24),

        // Description
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            community.description,
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 24),

        // Create Post Button
        ElevatedButton.icon(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userId = prefs.getString("userId");

            if (userId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePostPage(
                    userId: userId,
                    communityId: widget.community.id,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User ID not found")),
              );
            }
          },
          icon: const Icon(Icons.edit),
          label: const Text("Create Post"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),

        const SizedBox(height: 24),

        const Divider(),

        const Text(
          "Community Posts",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Posts List
        ...posts.map((post) => Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(post.title),
            subtitle: Text(post.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () {
              // Navigate to detailed post page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailsPage(post: post),
                ),
              );
            },
          ),
        )),

        if (isLoadingPosts)
          const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )),

        if (!hasMorePosts && posts.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No posts in this community."),
          )),
      ],
    ),
    );
  }
}
