import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/api/communityApi.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/pages/communities/communityHomeScreen.dart';
import 'package:women_safety/pages/communities/createCommunityScreen.dart';
import 'package:women_safety/pages/communities/exploreCommunities.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/noData.dart';

class ShowAllCommunities extends StatefulWidget {
  const ShowAllCommunities({super.key});

  @override
  State<ShowAllCommunities> createState() => _ShowAllCommunitiesState();
}

class _ShowAllCommunitiesState extends State<ShowAllCommunities> {
  List<Community> communities = [];
  bool isLoading = true;
  CommunityApi communityApi = CommunityApi();

  @override
  void initState() {
    super.initState();
    fetchUserCommunities();
  }

  Future<void> fetchUserCommunities() async {
    List<Community> data = await communityApi.getUserCommunities();
    setState(() {
      communities = data;
      isLoading = false;
    });
  }

  Future<void> _refreshUserCommunities() async{
    setState(() => isLoading = true);

    try {
      List<Community> newCommunities = await communityApi.getUserCommunities();

      setState(() {
        isLoading = false;
        communities = newCommunities;
      });
    } catch (err) {
      setState(() => isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        "Communities",
        onPressed: () {
          Navigator.pop(
            context,
            PageTransition(
              child: HomeScreen(),
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 400),
            ),
          );
        },
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
        leadingIcon: Icons.arrow_back,
        actions: [
          IconButton(
            icon: const Icon(Icons.explore, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExploreCommunitiesScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCommunityScreen()),
          );
        },
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add, size: 24),
        label: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Create Community",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),


      body: isLoading
          ? Loader(context)
          : communities.isEmpty
          ? noData("No communities followed")
          : RefreshIndicator(
        onRefresh: _refreshUserCommunities,
        child: ListView.builder(
          itemCount: communities.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            final community = communities[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: CommunityHomePage(community: community),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 400),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
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
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
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
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 28,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        )
        ,
      ),
    );
  }
}
