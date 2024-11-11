import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../api/mapApi.dart';
import '../../../consts/AppConts.dart';


class HospitalDescriptor extends StatefulWidget {
  final Map<String, dynamic> stationDetails;
  final LatLng initialPosition;
  final LatLng finalPosition;

  const HospitalDescriptor(
      {super.key,
        required this.stationDetails,
        required this.initialPosition,
        required this.finalPosition});

  @override
  State<HospitalDescriptor> createState() => _HospitalDescriptorState();
}

class _HospitalDescriptorState extends State<HospitalDescriptor> {
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
              widget.stationDetails['name'] ?? "Hospital",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Address
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(widget.stationDetails['formatted_address'] ?? 'Address not available'),
            ),

            // Phone Number
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(widget.stationDetails['formatted_phone_number'] ?? 'No Phone Number'),
            ),

            // Opening Hours
            if (widget.stationDetails['opening_hours'] != null)
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text(
                  widget.stationDetails['opening_hours']['weekday_text'] != null
                      ? widget.stationDetails['opening_hours']['weekday_text']
                      .join(', ')
                      : 'Opening hours not available',
                ),
              ),

            // Distance and Duration
            ListTile(
              leading: Icon(Icons.directions_walk),
              title: Text(distance ?? 'Calculating...'),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text(duration ?? 'Calculating...'),
            ),

            // Photo
            if (widget.stationDetails['photo_reference'] != null)
              Image.network(
                'https://maps.googleapis.com/maps/api/photo?maxwidth=400&photoreference=${widget.stationDetails['photo_reference']}&key=${GOOGLE_API_KEY}',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 10),

            // Reviews
            if (widget.stationDetails['reviews'] != null)
              for (var review in widget.stationDetails['reviews']) ...[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(review['profile_photo_url']),
                  ),
                  title: Text(review['author_name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rating: ${review['rating'].toString()}'),
                      Text(review['text'] ?? 'No review text'),
                      Text(review['relative_time_description']),
                    ],
                  ),
                ),
                Divider(),
              ],

            // Business Status
            if (widget.stationDetails['opening_hours'] != null )
              ListTile(
                title: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: widget.stationDetails['opening_hours']['open_now']
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      widget.stationDetails['opening_hours']['open_now']
                          ? 'Open Now'
                          : 'Closed',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
