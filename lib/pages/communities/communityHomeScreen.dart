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
  bool joinButtonLoading = false;
  List<Post> posts = [];
  int currentPage = 1;
  final int limit = 3;
  bool isLoadingPosts = false;
  bool hasMorePosts = true;
  final ScrollController _scrollController = ScrollController();
  final postsApi = PostApi();

  @override
  void initState() {
    super.initState();
    isMember();
    fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
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
    List<String> joinedCommunities =
        prefs.getStringList("communities") ?? [];
    setState(() {
      isJoined = joinedCommunities.contains(widget.community.id);
    });
  }

  void toggleJoinStatus() async {
    bool toggle;

    setState(() => joinButtonLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> joinedCommunities =
        prefs.getStringList("communities") ?? [];

    if (isJoined) {
      toggle = await communityApi.leaveCommunity(widget.community.id);
      joinedCommunities.remove(widget.community.id);
    } else {
      toggle = await communityApi.joinCommunity(widget.community.id);
      joinedCommunities.add(widget.community.id);
    }

    await prefs.setStringList("communities", joinedCommunities);

    setState(() {
      joinButtonLoading = false;
      if (toggle) isJoined = !isJoined;
    });
  }

  void fetchPosts() async {
    if (isLoadingPosts || !hasMorePosts) return;

    setState(() => isLoadingPosts = true);

    List<Post> newPosts = await postsApi.getCommunityPostsPaginated(
        currentPage, limit, widget.community.id);

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
        backgroundColor: Colors.green.shade900,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Community Info Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: community.imageUrl == "default.png"
                          ? NetworkImage(
                          "https://cdn.pixabay.com/photo/2020/06/06/19/23/lgbt-5267848_1280.png")
                      as ImageProvider
                          : NetworkImage(community.imageUrl),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      community.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${community.memberCount} members',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    joinButtonLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                      icon: Icon(
                          isJoined ? Icons.logout : Icons.group_add),
                      onPressed: toggleJoinStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isJoined ? Colors.grey : Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      label: Text(isJoined ? 'Leave Community' : 'Join Community'),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        community.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Post Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Create Post"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  String? userId = prefs.getString("userId");

                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostPage(
                          userId: userId,
                          communityId: community.id,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User ID not found")),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Community Posts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Posts
            if (posts.isEmpty && !isLoadingPosts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: const [
                    Icon(Icons.forum, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      "No posts in this community yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ...posts.map(
                  (post) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailsPage(post: post),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (post.images.isNotEmpty)
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: post.images.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    post.images[index],
                                    width: 200,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isLoadingPosts)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
