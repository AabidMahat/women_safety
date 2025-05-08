import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/api/communityApi.dart';
import 'package:women_safety/api/postsApi.dart';
import 'package:women_safety/pages/posts/CreatePostPage.dart';
import 'package:women_safety/pages/posts/postDetailPage.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/customAppBar.dart';

import '../../home_screen.dart';

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
    List<String> joinedCommunities = prefs.getStringList("communities") ?? [];
    setState(() {
      isJoined = joinedCommunities.contains(widget.community.id);
    });
  }

  void toggleJoinStatus() async {
    bool toggle;

    setState(() => joinButtonLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> joinedCommunities = prefs.getStringList("communities") ?? [];

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
      appBar: customAppBar(
        community.name,
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
        leadingIcon: Icons.arrow_back,
        onPressed: () {
          Navigator.pop(
            context,
            PageTransition(
              child: HomeScreen(),
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 1000),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Community Info Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: community.imageUrl == "default.png"
                              ? const AssetImage('assets/default.png')
                                  as ImageProvider
                              : NetworkImage(community.imageUrl),
                        ),
                        if (isJoined)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.check,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      community.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${community.memberCount} Members',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: toggleJoinStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isJoined
                              ? Colors.grey.shade400
                              : Colors.green.shade700,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isJoined ? "Leave Community" : "Join Community",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        community.description,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Post Button
            SizedBox(
              width: double.infinity,
              child: AdvanceButton(
                buttonText: "Create Post",
                backgroundColor: Colors.green.shade900,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.forum_rounded,
                      color: Colors.green.shade700, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "Community Posts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Posts
            if (posts.isEmpty && !isLoadingPosts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.forum_rounded,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "No posts in this community yet!",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ...posts.map((post) => Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  elevation: 3,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.black,
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
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
                          // Post title
                          Text(
                            post.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Post description
                          Text(
                            post.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          if (post.images.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 180,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.images.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 240,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade200,
                                        image: DecorationImage(
                                          image:
                                              NetworkImage(post.images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Bottom small post time or extra info
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                'Posted on ${DateFormat('dd MMM yyyy').format(community.createdAt)}',
                                // Make sure post.createdAt is formatted
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),

            if (isLoadingPosts)
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Loader(context),
              ),
          ],
        ),
      ),
    );
  }
}
