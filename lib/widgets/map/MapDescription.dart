import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../consts/AppConts.dart';


class PlaceDescription extends StatelessWidget {
  final Map<String, dynamic> stationDetails;

  const PlaceDescription({super.key, required this.stationDetails});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stationDetails['name'] ?? "Police Station",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            if (stationDetails['photo_reference'] != null)
              Image.network(
                'https://maps.googleapis.com/maps/api/photo?maxwidth=400&photoreference=${stationDetails['photo_reference']}&key=${GOOGLE_API_KEY}',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(stationDetails['formatted_phone_number'] ??
                  "No Phone Number"),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title:
                  Text(stationDetails['vicinity'] ?? 'Address not available'),
            ),
            if (stationDetails['business_status'] != null)
              ListTile(
                leading: Icon(Icons.access_time),
                title: Container(
                  width: MediaQuery.of(context).size.width*0.4,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: stationDetails['business_status'] == 'OPERATIONAL'
                          ? Colors.green.shade900
                          : Colors.red.shade900),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      stationDetails['business_status'] == 'OPERATIONAL'
                          ? 'Open Now'
                          : 'close',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
