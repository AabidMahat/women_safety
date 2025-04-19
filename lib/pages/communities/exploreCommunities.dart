import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/api/communityApi.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/noData.dart';
import 'package:women_safety/Database/Database.dart';

import 'communityHomeScreen.dart';

class ExploreCommunitiesScreen extends StatefulWidget {
  const ExploreCommunitiesScreen({super.key});

  @override
  State<ExploreCommunitiesScreen> createState() => _ExploreCommunitiesScreenState();
}

class _ExploreCommunitiesScreenState extends State<ExploreCommunitiesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Community> _communities = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  final int _limit = 5;

  CommunityApi communityApi = CommunityApi();

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
        _fetchCommunities();
      }
    });
  }

  Future<void> _fetchCommunities() async {
    setState(() => _isLoading = true);

    try {
      List<Community> newCommunities = await communityApi.getAllCommunitiesPaginated(_currentPage, _limit);

      setState(() {
        _currentPage++;
        _isLoading = false;
        _hasMore = newCommunities.length == _limit;
        _communities.addAll(newCommunities);
      });
    } catch (err) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Communities"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _communities.length + (_isLoading ? 1 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            if (index < _communities.length) {
              final community = _communities[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundImage: community.imageUrl == "default.png" ?
                      NetworkImage("https://people.math.sc.edu/Burkardt/data/png/washington.png") as ImageProvider
                          : NetworkImage(community.imageUrl) as ImageProvider
                  ),
                  title: Text(community.name),
                  subtitle: Text(community.description),
                  onTap: () {
                    Navigator.push(context, PageTransition(
                        child: CommunityHomePage(community: community),
                        type: PageTransitionType.leftToRight,
                        duration: Duration(milliseconds: 400)));
                  },
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}
