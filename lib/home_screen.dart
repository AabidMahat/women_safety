import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/EmergencyCall.dart';
import 'package:women_safety/api/Permission.dart';
import 'package:women_safety/pages/videos/DisplayAllVideos.dart';
import 'package:women_safety/pages/DisplayAudios.dart';
import 'package:women_safety/utils/quotes.dart';
import 'package:women_safety/widgets/Live_Safe.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/home_widgets/Emergency.dart';
import 'package:women_safety/widgets/home_widgets/customAppBar.dart';
import 'package:women_safety/widgets/home_widgets/safeHome/SafeHome.dart';
import 'package:women_safety/widgets/makeCallConfirmation.dart';

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
  EmergencyCallApi emergencyCallApi = EmergencyCallApi();
  void getRandomQuote() {
    Random random = Random();

    setState(() {
      qIndex = random.nextInt(Quotes.length); // Ensure it works for all quotes
    });
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    getRandomQuote();
    getPermission();
    getSmsPermission();
    _requestPhoneStatePermission();
    emergencyCallApi.startListening();
    super.initState();

  }

  Future<void> _requestPhoneStatePermission() async {
    await permissionApi.requestPhoneStatePermission();
  }

  void getPermission() async {
    Position? location = await permissionApi.getUserLocation();
    setState(() {
      currentPosition = location;
    });
    await userLocation(location!);
  }

  void getSmsPermission()async{
    await permissionApi.requestSmsPermission();
  }
  
  Future<void> userLocation(Position location)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("userLocation", json.encode(location));
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
          floatingActionButton: FloatingActionButton(
            splashColor: Colors.white,
            backgroundColor: Colors.white,
            onPressed: (){
              stopCallScheduler();
            },
            child: Icon(Icons.call_end,size: 28,),
          ),
          bottomNavigationBar: BottomNavigationBar(
            elevation: 3,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28), // Set a fixed size
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.slow_motion_video, size: 28), // Set a fixed size
                label: 'Video',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.audiotrack, size: 28), // Set a fixed size
                label: 'Audio',
              ),
            ],
            selectedItemColor: Colors.teal[800],
            unselectedItemColor: Colors.black,
            showUnselectedLabels: true,
            onTap: (index) {
              switch (index) {
                case 0:
                // Navigate to HomeScreen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                  break;

                case 1:
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ShowAllVideo()));
                  break;
                case 2:
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ShowAudios()));
                  break;

              }
            },
          ),
        ),
      ),
    );
  }
}
