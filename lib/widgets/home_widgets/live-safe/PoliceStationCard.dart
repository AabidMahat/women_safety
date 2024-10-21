import 'package:flutter/material.dart';

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
               onTap: (){
                 Navigator.push(context, MaterialPageRoute(builder: (context) => PoliceStation(),));
               },
               child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Container(
                  height: 50,
                  width: 50,
               
                  child: Center(
                    child: Image.asset("assets/policebadge.png",height: 45,),
               
                  ),
               
                ),
                           ),
             ),
          Text("Police Stations")

        ],
      ),
    );
  }
}
