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

  @override
  void initState() {
    super.initState();
    fetchUserCommunities();
  }

  Future<void> fetchUserCommunities() async {
    CommunityApi communityApi = CommunityApi();
    List<Community> data = await communityApi.getUserCommunities();
    setState(() {
      communities = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext buildContext) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCommunityScreen()),
          );
        },
        backgroundColor: Colors.green.shade900,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? Loader(context)
          : communities.isEmpty
          ? noData("no communities followed")
          : ListView.builder(
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community = communities[index];
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
        },
      ),
    );
  }
}
