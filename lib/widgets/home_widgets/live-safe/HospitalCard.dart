import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:women_safety/widgets/map/hospitalMap.dart';

class HospitalCard extends StatelessWidget {
  const HospitalCard({super.key});

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
                      child: HospitalMap(),
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
                    "assets/Hospital.png",
                    height: 45,
                  ),
                ),
              ),
            ),
          ),
          Text(
            "Hospitals",
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
