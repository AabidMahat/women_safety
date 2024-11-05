import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/api/EmergencyCall.dart';
import 'package:women_safety/api/Permission.dart';
import 'package:women_safety/api/sendNotification.dart';
import 'package:women_safety/pages/videos/DisplayAllVideos.dart';
import 'package:women_safety/pages/DisplayAudios.dart';
import 'package:women_safety/utils/quotes.dart';
import 'package:women_safety/utils/shake.dart';
import 'package:women_safety/widgets/Live_Safe.dart';
import 'package:women_safety/widgets/customAppBar.dart';
import 'package:women_safety/widgets/home_widgets/Emergency.dart';
import 'package:women_safety/widgets/home_widgets/customAppBar.dart';
import 'package:women_safety/widgets/home_widgets/safeHome/SafeHome.dart';
import 'package:women_safety/widgets/makeCallConfirmation.dart';



import 'Profile.dart';
import 'api/Firebase_api.dart';
import 'widgets/home_widgets/CustomCaroucel.dart';




void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int qIndex = 0;
  Position? currentPosition;
  PermissionApi permissionApi = PermissionApi();
  EmergencyCallApi emergencyCallApi = EmergencyCallApi();

  List<String> userId = ["670f3cd307565c85a58b096b"];

  void getRandomQuote() {
    Random random = Random();

    setState(() {
      qIndex = random.nextInt(Quotes.length); // Ensure it works for all quotes
    });
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    initPermission();
    storeToken();
    getRandomQuote();
    emergencyCallApi.startListening();
    ShakeAndButtonCombo();
    super.initState();
  }

  Future<void> initPermission() async {
    await getPermission();
    await getSmsPermission();
    await _requestPhoneStatePermission();
  }

  Future<void> _requestPhoneStatePermission() async {
    await permissionApi.requestPhoneStatePermission();
  }

  Future<void> getPermission() async {
    Position? location = await permissionApi.getUserLocation();
    setState(() {
      currentPosition = location;
    });
    await userLocation(location!);
  }

  Future<void> getSmsPermission() async {
    await permissionApi.requestSmsPermission();
  }

  void getStoragePermission() async {
    await permissionApi.requestStoragePermission();
  }

  void storeToken() async {
    await FirebaseApi().checkAndUpdateFCMToken();
  }

  Future<void> userLocation(Position location) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("userLocation", json.encode(location));
  }

  

  @override
  void dispose() {
    // TODO: implement dispose
    ShakeAndButtonCombo().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: customAppBar("Dashboard", onPressed: () {
        _scaffoldKey.currentState?.openDrawer();
      },
          backgroundColor: Colors.green.shade900,
          textColor: Colors.white,
          leadingIcon: Icons.menu),
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Emergency",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Emergency(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Explore LiveSafe",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        onPressed: () {
          stopCallScheduler();
        },
        child: Icon(
          Icons.call_end,
          size: 28,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28), // Set a fixed size
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over, size: 28),
            // Set a fixed size
            label: 'Recording',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add, size: 28),
            // Set a fixed size
            label: 'Notify',
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
              SendNotification().triggerRecording();
              break;
            case 2:
              SendNotification().sendNotification(
                  "Demo Notification", "For trial Purpose", ["670f3cd307565c85a58b096b"]);
              break;
          }
        },
      ),
    );
  }
}
