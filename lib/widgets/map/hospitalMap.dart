import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:women_safety/utils/loader.dart';
import 'package:women_safety/widgets/map/descriptors/HospitalDescriptor.dart';

import '../../consts/AppConts.dart';

class HospitalMap extends StatefulWidget {
  const HospitalMap({super.key});

  @override
  State<HospitalMap> createState() => _HospitalMapState();
}

class _HospitalMapState extends State<HospitalMap> {
  BitmapDescriptor? policeIcon;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng ?_initialPosition;
  LatLng? _finalPosition;
  Set<Marker> _marker = {};
  Set<Polyline> _polyline = {};
  final List<LatLng> _polylineCoordinates = [];

  @override
  void initState() {
    _getUserLocation();
    setUpIcon();
    super.initState();
  }

  void setUpIcon() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      'assets/markers/hospital.png',
    ).then((icon) {
      setState(() {
        policeIcon = icon;
      });
    }).catchError((e) {
      print("Error loading icon: $e");
      Fluttertoast.showToast(msg: "Failed to load police icon.");
    });
  }

  Future<void> _getUserLocation() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location Permission is denied");
        return;
      } else if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission is denied forever");
        return;
      }
    }

    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true,
    ).then((Position position) {
      setState(() {
        _currentPosition = position;
        _initialPosition = LatLng(position.latitude, position.longitude);
        _addCurrentLocationMarker();
      });

      if (_currentPosition != null) {
        _getNearbyBusStations();
      } else {
        Fluttertoast.showToast(msg: "Failed to get current location.");
      }
    }).catchError((e) {
      Fluttertoast.showToast(msg: "Failed to get current location.");
    });
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      final currentLocationMarker = Marker(
          markerId: MarkerId('current_location'),
          position:
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: "Your Location"));

      setState(() {
        _marker.add(currentLocationMarker);
      });
    }
  }

  Future<void> _getNearbyBusStations() async {
    final apiKey = GOOGLE_API_KEY;
    final radius = 5000;

    print(apiKey);

    final baseURl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    final url =
        '$baseURl?location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=$radius&type=hospital&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    print("Response ${json.decode(response.body)}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && policeIcon != null) {
        for (var place in data['results']) {
          // Fetch and display the details including the phone number
          _getBusStationDetails(place);
        }
      } else {
        Fluttertoast.showToast(msg: "No police stations found nearby.");
      }
    } else {
      Fluttertoast.showToast(msg: "Failed to fetch nearby police stations.");
    }
  }

  Future<void> _getBusStationDetails(Map<String, dynamic> place) async {
    final apiKey = GOOGLE_API_KEY;
    final placeId = place['place_id'];
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    print(url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      if (data['status'] == 'OK') {
        final result = data['result'];

        final phoneNumber =
            result['formatted_phone_number'] ?? 'No phone available';

        // Create a marker with the police station details
        final marker = Marker(
            markerId: MarkerId(placeId),
            position: LatLng(
              place['geometry']['location']['lat'],
              place['geometry']['location']['lng'],
            ),
            icon: policeIcon!,
            onTap: () {
              print(result);
              _getRouteToMarker(LatLng(
                place['geometry']['location']['lat'],
                place['geometry']['location']['lng'],
              ));
              setState(() {
                _finalPosition = LatLng(
                  place['geometry']['location']['lat'],
                  place['geometry']['location']['lng'],
                );
              });
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return HospitalDescriptor(
                      stationDetails: result,
                      initialPosition: _initialPosition!,
                      finalPosition: _finalPosition!,
                    );
                  });
            });

        // Update the markers on the map
        setState(() {
          _marker.add(marker);
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch police station details.");
      }
    } else {
      Fluttertoast.showToast(msg: "Failed to fetch police station details.");
    }
  }

  Future<void> _getRouteToMarker(LatLng destination) async {
    final apiKey = GOOGLE_API_KEY;

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final polyline = routes[0]['overview_polyline']['points'];
          _decodePolyline(polyline);
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch route.");
      }
    } else {
      Fluttertoast.showToast(msg: "Failed to fetch route.");
    }
  }

  void _decodePolyline(String encodedPolyline) {
    final List<LatLng> points = _convertToLatLng(_decodePoly(encodedPolyline));
    setState(() {
      _polyline.add(Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: points,
      ));
    });
  }

  List<LatLng> _convertToLatLng(List<PointLatLng> points) {
    return points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
  }

  List<PointLatLng> _decodePoly(String encoded) {
    List<PointLatLng> poly = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      PointLatLng point = PointLatLng(
        (lat / 1E5).toDouble(),
        (lng / 1E5).toDouble(),
      );
      poly.add(point);
    }
    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? Loader(context)
          : GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(
                _currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14.0),
        markers: _marker,
        polylines: _polyline,
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
      ),
    );
  }
}
