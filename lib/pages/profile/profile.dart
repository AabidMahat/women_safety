import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/api/Guardian.dart';
import 'package:women_safety/api/User.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/pages/childrensAssigned.dart';
import 'package:women_safety/pages/profile/updateProfile.dart';
import 'package:women_safety/pages/requests/request.dart';
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/Button/ResuableButton.dart';
import 'package:women_safety/widgets/cards/cards.dart';

import '../DisplayAudios.dart';
import '../videos/DisplayAllVideos.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserData? user;
  UserApi userApi = UserApi();

  @override
  void initState() {
    getGuardian();
    super.initState();
  }

  void getGuardian() async {
    UserData? data = await userApi.getUserProfile();

    setState(() {
      user = data;
    });

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: HomeScreen(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 400)));
        return false;
      },
      child: Scaffold(
        body: user == null
            ? Loader(context)
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade900,
                                Colors.green.shade700
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade900.withOpacity(0.5),
                                blurRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundImage: user!.avatar == null
                                      ? const AssetImage(
                                          "default.png", // Placeholder avatar
                                        )
                                      : NetworkImage(user!.avatar)
                                          as ImageProvider,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                user!.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54, // Shadow color
                                      blurRadius: 2, // Shadow blur
                                      offset: Offset(2, 2), // Shadow offset
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Phone Number Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: AdvancedCard(
                        cardTitle: "Phone Number",
                        cardInfo: user!.phoneNumber,
                        cardIcons: Icons.phone,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: AdvancedCard(
                        cardTitle: "Email",
                        cardInfo: user!.email,
                        cardIcons: Icons.email,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: AdvancedCard(
                        cardTitle: "Address",
                        cardInfo: "123 Example Street", // Placeholder address
                        cardIcons: Icons.location_on,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: RequestPage(),
                                  type: PageTransitionType.leftToRight,
                                  duration: Duration(milliseconds: 400)));
                        },
                        child: AdvancedCard(
                          cardTitle: "Requests",
                          cardInfo: "Tap to view",
                          cardIcons: Icons.add,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildrenAssigned(),
                              ));
                        },
                        child: AdvancedCard(
                          cardTitle: "Guardians",
                          cardInfo: "Tap to view", // Placeholder address
                          cardIcons: Icons.family_restroom,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  child: ShowAllVideo(),
                                  duration: Duration(milliseconds: 500)));
                        },
                        child: AdvancedCard(
                          cardTitle: "Videos",
                          cardInfo: "Tap to view", // Placeholder address
                          cardIcons: Icons.videocam_rounded,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  duration: Duration(milliseconds: 500),
                                  child: ShowAudios()));
                        },
                        child: AdvancedCard(
                          cardTitle: "Audios",
                          cardInfo: "Tap to view", // Placeholder address
                          cardIcons: Icons.audiotrack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

        // Move bottomNavigationBar out of the body
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // This will allow the row to take only the space it needs
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: AdvanceButton(
                  prefixIcon: Icons.delete,
                  onPressed: () {
                    // Add delete functionality here
                  },
                  buttonText: "Delete",
                  backgroundColor: Colors.red.shade900,
                ),
              ),
              const SizedBox(width: 10), // Add space between the buttons
              Expanded(
                child: AdvanceButton(
                  prefixIcon: Icons.edit,
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            duration: Duration(milliseconds: 500),
                            child: UpdateProfile(
                              user: user!,
                            )));
                  },
                  buttonText: "Edit",
                  backgroundColor: Colors.green.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
