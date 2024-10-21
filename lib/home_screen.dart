import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:women_safety/api/Permission.dart';
import 'package:women_safety/utils/quotes.dart';
import 'package:women_safety/widgets/Live_Safe.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/home_widgets/Emergency.dart';
import 'package:women_safety/widgets/home_widgets/customAppBar.dart';
import 'package:women_safety/widgets/home_widgets/safeHome/SafeHome.dart';

import 'Profile.dart';
import 'widgets/home_widgets/CustomCaroucel.dart';





class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 0;
  Position? currentPosition;
  PermissionApi permissionApi = PermissionApi();

  void getRandomQuote() {
    Random random = Random();

    setState(() {
      qIndex = random.nextInt(Quotes.length); // Ensure it works for all quotes
    });
  }

  @override
  void initState() {
    getRandomQuote();
    getPermission();
    super.initState();

  }

  void getPermission() async {
    Position? location = await permissionApi.getUserLocation();
    setState(() {
      currentPosition = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop:()async{
          print("Button pressed");
          return false;
        },
        child: Scaffold(
          appBar: customAppBar(
            "Dashboard",
            onPressed: () {},
            backgroundColor: Colors.green.shade900,
            textColor: Colors.white,
          ),
          drawer: SideBarWidget(
            currentPosition: currentPosition,
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomAppBar(
                      quoteIndex: qIndex,
                      onTap:
                          getRandomQuote, // Pass the function reference, not call
                    ),
                    CustomCaroucel(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Emergency",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Emergency(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Explore LiveSafe",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    LiveSafe(),
                    SafeHome(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
