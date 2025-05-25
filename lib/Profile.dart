import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety/Database/Database.dart';
import 'package:women_safety/FeedBack/FeedBackMap.dart';
import 'package:women_safety/api/User.dart';
import 'package:women_safety/api/sendNotificationApi.dart';
import 'package:women_safety/pages/LogIn/Login.dart';
import 'package:women_safety/pages/profile/profile.dart';
import 'package:women_safety/pages/settings/messageTemplates.dart';
import 'package:women_safety/utils/Procupine.dart';
import 'package:women_safety/widgets/sidebar/emergency/EmergencyContacts.dart';

class SideBarWidget extends StatefulWidget {
  final Position? currentPosition;

  const SideBarWidget({super.key, this.currentPosition});

  @override
  State<SideBarWidget> createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  bool isLoading = true;
  bool isUserLoading = true;
  String? staffAccess;
  late String userId;
  bool isHandGestureEnabled = false;

  bool isLogOut = false;
  String userPhone = '';
  String name = "";
  String avatar = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userPhone = preferences.getString("phoneNumber") ?? "Phone Number";
      name = preferences.getString("username")!;
      userId = preferences.getString("userId") ?? "";
      avatar = preferences.getString("avatar") ?? "";
    });

    print("Avatar :_ " + preferences.getString("avatar")!);
  }

  void logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.push(
        context,
        PageTransition(
            child: NewLoginPage(),
            type: PageTransitionType.leftToRight,
            duration: Duration(milliseconds: 400)));
  }

  @override
  Widget build(BuildContext context) {
    print("Sidebar $staffAccess");
    return Scaffold(
      body: Container(
          width: MediaQuery.sizeOf(context).width,
          child: Drawer(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 16,
              child: Align(
                alignment: AlignmentDirectional(-1, -1),
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 0,
                        color: Colors.green.shade900,
                        offset: Offset(1, 0),
                      )
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    shape: BoxShape.rectangle,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 59, 0, 24),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green[900],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.shade900,
                                  offset: Offset(0, 1),
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16, 20, 16, 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        width: 95,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade900,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.green.shade900,
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: avatar == null ||
                                                  avatar == "default.png"
                                              ? Image.network(
                                                  'https://images.unsplash.com/photo-1624561172888-ac93c696e10c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NjJ8fHVzZXJzfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  avatar,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$name',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 4, 0, 0),
                                                child: Text(
                                                  '$userPhone',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    color: Color(0x9AFFFFFF),
                                                    fontSize: 14,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    AlignmentDirectional(-1, 0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 29, 0, 0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          PageTransition(
                                                            child:
                                                                ProfilePage(),
                                                            type:
                                                                PageTransitionType
                                                                    .leftToRight,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    400),
                                                          ));
                                                    },
                                                    child: Text(
                                                      'Edit Profile',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Plus Jakarta Sans',
                                                        color:
                                                            Color(0x9AFFFFFF),
                                                        fontSize: 16,
                                                        letterSpacing: 0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EmergencyContacts(userId: userId),
                                ));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: Color(0x84BDBDBD),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(22, 0, 12, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.person_pin_outlined,
                                    color: Colors.green.shade900,
                                    size: 28,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12, 0, 0, 0),
                                    child: Text(
                                      'My Emergency Contacts',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Colors.green.shade800,
                                        fontSize: 17,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(0),
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: Color(0x84BDBDBD),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(22, 0, 12, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  CupertinoIcons.map_pin_ellipse,
                                  color: Colors.green.shade800,
                                  size: 28,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12, 0, 0, 0),
                                  child: Text(
                                    'Live location',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Colors.green.shade800,
                                      fontSize: 17,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            SendNotification().sendVideoRecordingNotification();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: Color(0x84BDBDBD),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(22, 0, 12, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.slow_motion_video_outlined,
                                    color: Colors.green.shade800,
                                    size: 26,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12, 0, 0, 0),
                                    child: Text(
                                      'Video Recording',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Colors.green.shade800,
                                        fontSize: 17,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    duration: Duration(milliseconds: 500),
                                    type: PageTransitionType.leftToRight,
                                    child: VoiceCommand()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: Color(0x84BDBDBD),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(22, 0, 12, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.record_voice_over,
                                    color: Colors.green.shade800,
                                    size: 28,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12, 0, 0, 0),
                                    child: Text(
                                      'Voice Commands',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Colors.green.shade800,
                                        fontSize: 17,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: widget.currentPosition != null
                              ? () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FeedbackScreen(
                                              currentPosition: LatLng(
                                                  widget.currentPosition!
                                                      .latitude,
                                                  widget.currentPosition!
                                                      .longitude))));
                                }
                              : null,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: Color(0x84BDBDBD),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(22, 0, 12, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.feedback_outlined,
                                    color: Colors.green.shade800,
                                    size: 28,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12, 0, 0, 0),
                                    child: Text(
                                      'Feedbacks',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Colors.green.shade800,
                                        fontSize: 17,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: MessageTemplate(),
                                    type: PageTransitionType.leftToRight,
                                    duration: Duration(milliseconds: 400)));
                          },
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: MessageTemplate(),
                                      type: PageTransitionType.leftToRight,
                                      duration: Duration(milliseconds: 400)));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(0),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0x84BDBDBD),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    22, 0, 12, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: Colors.green.shade800,
                                      size: 28,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12, 0, 0, 0),
                                      child: Text(
                                        'Settings',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Colors.green.shade800,
                                          fontSize: 17,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12, 0, 12, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: Align(
                                          alignment: AlignmentDirectional(0, 0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              primary: Colors.green.shade800,
                                            ),
                                            onPressed: () {
                                              logOut();
                                            },
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(24, 0, 24, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // FaIcon(
                                                  //   Icons.logout_sharp,
                                                  //   color: Colors.white,
                                                  //   size: 26,
                                                  // ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Log Out',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Plus Jakarta Sans',
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    'App version 1.0.0',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.green.shade800,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))),
    );
  }
}
