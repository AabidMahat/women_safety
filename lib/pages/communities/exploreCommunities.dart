import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/api/communityApi.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/noData.dart';
import 'package:women_safety/Database/Database.dart';

import '../../home_screen.dart';
import 'communityHomeScreen.dart';

class ExploreCommunitiesScreen extends StatefulWidget {
  const ExploreCommunitiesScreen({super.key});

  @override
  State<ExploreCommunitiesScreen> createState() =>
      _ExploreCommunitiesScreenState();
}

class _ExploreCommunitiesScreenState extends State<ExploreCommunitiesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Community> _communities = [];
  int _currentPage = 1;
  bool _isLoading = true;
  bool _hasMore = true;

  final int _limit = 5;

  CommunityApi communityApi = CommunityApi();

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchCommunities();
      }
    });
  }

  Future<void> _fetchCommunities() async {
    setState(() => _isLoading = true);

    try {
      List<Community> newCommunities =
          await communityApi.getAllCommunitiesPaginated(_currentPage, _limit);

      setState(() {
        _currentPage++;
        _isLoading = false;
        _hasMore = newCommunities.length == _limit;
        _communities.addAll(newCommunities);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.position.maxScrollExtent <=
                _scrollController.position.viewportDimension &&
            _hasMore) {
          _fetchCommunities();
        }
      });
    } catch (err) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshUserCommunities() async {
    setState(() => _isLoading = true);

    try {
      setState(() {
        _currentPage = 1;
      });
      List<Community> newCommunities =
          await communityApi.getAllCommunitiesPaginated(_currentPage, _limit);

      setState(() {
        _currentPage++;
        _isLoading = false;
        _hasMore = newCommunities.length == _limit;
        _communities = newCommunities;
      });
    } catch (err) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Explore Communities",
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
        leadingIcon: Icons.arrow_back,
        onPressed: () {
          Navigator.pop(
            context,
            PageTransition(
              child: HomeScreen(),
              type: PageTransitionType.rightToLeft,
              duration: Duration(milliseconds: 400),
            ),
          );
        },
      ),
      body: Container(
        color: Colors.grey[100],
        child: _communities.isEmpty && _isLoading
            ? Loader(context)
            : _communities.isEmpty
                ? noData("No communities found")
                : RefreshIndicator(
                    onRefresh: _refreshUserCommunities,
                    child: ListView.builder(
                      itemCount: _communities.length +
                          (_isLoading && _hasMore ? 1 : 0),
                      physics: const AlwaysScrollableScrollPhysics(),
                      // important for pull even when full
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        if (index < _communities.length) {
                          final community = _communities[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  child:
                                      CommunityHomePage(community: community),
                                  type: PageTransitionType.leftToRight,
                                  duration: const Duration(milliseconds: 400),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: community.imageUrl == "default.png"
                                        ? const AssetImage("assets/default.png") as ImageProvider
                                        : NetworkImage(community.imageUrl),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          community.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          community.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          );
                        } else {
                          return Loader(context);
                        }
                      },
                    ),
                  ),
      ),
    );
  }
}
