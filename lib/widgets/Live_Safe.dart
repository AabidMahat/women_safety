import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_widgets/live-safe/BusStationCard.dart';
import 'home_widgets/live-safe/HospitalCard.dart';
import 'home_widgets/live-safe/PharmacyCard.dart';
import 'home_widgets/live-safe/PoliceStationCard.dart';
import 'map/policeMap.dart';

class LiveSafe extends StatelessWidget {
  const LiveSafe({super.key});

  static Future<void> openMap(String location)async{
    String googleUrl='https://www.google.com/maps/search/$location';
    final Uri _url=Uri.parse(googleUrl);
    try{
      await launchUrl(_url);
    }catch(e){
        Fluttertoast.showToast(msg: "Something went wrong call emergency number");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics: BouncingScrollPhysics(
        ),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceStationCard(),
          HospitalCard(onMapFunction: openMap),
          PharmacyCard(onMapFunction: openMap),
          BusStationCard(onMapFunction: openMap)
        ],
      ),
    );
  }
}
