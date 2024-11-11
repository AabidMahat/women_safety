import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../map/policeMap.dart';

class PoliceStationCard extends StatelessWidget {
  final Function? onMapFunction;

  const PoliceStationCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: PoliceStation(),
                      type: PageTransitionType.leftToRight,
                      duration: Duration(milliseconds: 400)));
            },
            child: Card(
              elevation: 3,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset(
                    "assets/policebadge.png",
                    height: 45,
                  ),
                ),
              ),
            ),
          ),
          Text(
            "Police Stations",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Slightly softer than pure black
            ),
          )
        ],
      ),
    );
  }
}
