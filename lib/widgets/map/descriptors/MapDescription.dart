import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../api/mapApi.dart';
import '../../../consts/AppConts.dart';


class PlaceDescription extends StatefulWidget {
  final Map<String, dynamic> stationDetails;
  final LatLng initialPosition;
  final LatLng finalPosition;

  const PlaceDescription(
      {super.key,
        required this.stationDetails,
        required this.initialPosition,
        required this.finalPosition});

  @override
  State<PlaceDescription> createState() => _PlaceDescriptionState();
}

class _PlaceDescriptionState extends State<PlaceDescription> {
  MapApi _mapApi = MapApi();
  String? distance;
  String? duration;

  @override
  void initState() {
    _mapApi
        .getDistanceAndDuration(widget.initialPosition, widget.finalPosition)
        .then((result) {
      if (result != null) {
        setState(() {
          distance = result['distance'];
          duration = result['duration'];
        });
        Fluttertoast.showToast(
            msg:
            "Distance: ${result['distance']} | Duration: ${result['duration']}");
      } else {
        Fluttertoast.showToast(msg: 'Failed to get distance and time');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.stationDetails['name'] ?? "Police Station",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            if (widget.stationDetails['photo_reference'] != null)
              Image.network(
                'https://maps.googleapis.com/maps/api/photo?maxwidth=400&photoreference=${widget.stationDetails['photo_reference']}&key=${GOOGLE_API_KEY}',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(widget.stationDetails['formatted_phone_number'] ??
                  "No Phone Number"),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(
                  widget.stationDetails['vicinity'] ?? 'Address not available'),
            ),
            ListTile(
              leading: Icon(Icons.time_to_leave),
              title: Text(distance ?? 'Calculating...'),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text(duration ?? 'Calculating...'),
            ),
            if (widget.stationDetails['business_status'] != null)
              ListTile(
                title: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: widget.stationDetails['business_status'] ==
                          'OPERATIONAL'
                          ? Colors.green.shade900
                          : Colors.red.shade900),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      widget.stationDetails['business_status'] == 'OPERATIONAL'
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
