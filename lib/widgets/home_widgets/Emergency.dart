import 'package:flutter/material.dart';

import 'emergencies/AmbulanceEmergencies.dart';
import 'emergencies/ArmyEmergency.dart';
import 'emergencies/FireBrigadeEmergency.dart';
import 'emergencies/policeEmergency.dart';

class Emergency extends StatelessWidget {
  const Emergency({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceEmergency(),
          AmbulanceEmergency(),
          FireBrigadeEmergency(),
          ArmyEmergency()
        ],
      ),
    );
  }
}
