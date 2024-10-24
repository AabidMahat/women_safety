import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import 'package:women_safety/api/mapApi.dart';

import '../consts/AppConts.dart';

void main() {
  runApp(MaterialApp(
    home: LiveLocation(),
  ));
}

class LiveLocation extends StatefulWidget {
  const LiveLocation({super.key});

  @override
  State<LiveLocation> createState() => _LiveLocationState();
}

class _LiveLocationState extends State<LiveLocation> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController =
  Completer<GoogleMapController>();

  LatLng? _currentPosition = null;

  String placeName = "";

  LatLng initialPosition = LatLng(16.69531, 74.1987433);
  LatLng finalPosition = LatLng(16.6984, 74.2289);

  Map<PolylineId, Polyline> polylines = {};

  Set<Circle> _circles = {};

  MapApi mapAPI = new MapApi();

  late IOWebSocketChannel _webSocketChannel;
  String ? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
    _connectWebSocket();
    getLocationAndUpdate().then((_) => getRoutesWithAlternatives()
        .then((routes) => displayRoutesOnMap(routes)));
  }

  void getUserId()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('userId');
  }

  // Connect to web socket

  void _connectWebSocket() {
    _webSocketChannel = IOWebSocketChannel.connect(
        '${WEBSOCKETURL}/live-location');
    // IOWebSocketChannel.connect('ws://10.0.2.2:3000/live-location');

    _webSocketChannel.stream.listen((message) {
      var data = jsonDecode(message);
      print(data);
      if (data['latitude'] != null && data['longitude'] != null) {
        setState(() {
          _currentPosition = LatLng(data['latitude'], data['longitude']);
          _updateCircle();
        });
      }
    });
  }

  Future<void> getLocationAndUpdate() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();

    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();

      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationController.changeSettings(interval: 1000);
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          initialPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
        // _cameraPosition(_currentPosition!);
        _updateCircle();

        //   Send location to the WebSocket server
        _webSocketChannel.sink.add(jsonEncode({
          'type': 'locationUpdate',
          'userId': userId,
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
          'timestamp': DateTime.now().toIso8601String(),
        }));
      }
    });
  }
  Future<List<List<LatLng>>> getRoutesWithAlternatives() async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$GOOGLE_API_KEY&alternatives=true";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      List<List<LatLng>> routes = [];

      if (data['routes'] != null) {
        for (var route in data['routes']) {
          List<LatLng> polylineCoords = [];
          var points = route['overview_polyline']['points'];
          polylineCoords.addAll(_decodePolyline(points));
          routes.add(polylineCoords);
        }
      }
      return routes;
    } else {
      Fluttertoast.showToast(msg: "Error fetching routes");
      return [];
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      coordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return coordinates;
  }

  void displayRoutesOnMap(List<List<LatLng>> routes) {
    setState(() {
      polylines.clear();
      for (int i = 0; i < routes.length; i++) {
        PolylineId id = PolylineId('polyline_$i');
        Polyline polyline = Polyline(
          polylineId: id,
          color: i == 0 ? Colors.blue.shade900 : Colors.grey,
          // Highlight first route
          width: 6,
          points: routes[i],
        );
        polylines[id] = polyline;
      }
    });
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> polylineCoords = [];

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_API_KEY,
      PointLatLng(initialPosition.latitude, initialPosition.longitude),
      PointLatLng(finalPosition.latitude, finalPosition.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoords.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      Fluttertoast.showToast(msg: result.errorMessage!);
    }
    return polylineCoords;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinate) async {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue.shade900,
        width: 6,
        points: polylineCoordinate);

    setState(() {
      polylines[id] = polyline;
    });
  }

  void _updateCircle() {
    if (_currentPosition != null) {
      setState(() {
        _circles.clear();
        _circles.add(
          Circle(
              circleId: CircleId("currentLocationCircle"),
              center: _currentPosition!,
              radius: 10,
              strokeColor: Colors.blueAccent,
              strokeWidth: 2,
              fillColor: Colors.blueAccent.withOpacity(0.2)),
        );
      });
    }
  }

  void _showDistanceAndTime(String distance, String time) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Text("Distance $distance & Time $time");
        });
  }

  @override
  void dispose() {
    _webSocketChannel.sink.close();
    super.dispose();
  }

  Widget _buildSearchbar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextFormField(
        style: TextStyle(
          color: Colors.white, // Set text color to white
          fontFamily: 'Readex Pro',
        ),
        keyboardType: TextInputType.name,
        onFieldSubmitted: (value) async {
          setState(() {
            placeName = value;
          });
          var position = await mapAPI.getLatLngFromPlaces(placeName);
          if (position != null) {
            setState(() {
              finalPosition = LatLng(position['lat'], position['lng']);
            });

            // Once final location is set, generate the polyline route
            getLocationAndUpdate().then((_) => getRoutesWithAlternatives()
                .then((routes) => displayRoutesOnMap(routes)));

            //   Fetch Distance and Time

            mapAPI
                .getDistanceAndDuration(initialPosition, finalPosition)
                .then((result) {
              if (result != null) {
                _showDistanceAndTime(result['distance'], result['duration']);
                Fluttertoast.showToast(
                    msg:
                    "Distance: ${result['distance']} | Duration: ${result['duration']}");
              } else {
                Fluttertoast.showToast(msg: 'Failed to get distance and time');
              }
            });
          } else {
            Fluttertoast.showToast(msg: 'Location not found');
          }
        },
        decoration: InputDecoration(
          fillColor: Colors.black87,
          filled: true,
          contentPadding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          suffixIcon: Icon(
            Icons.search,
            color: Colors.white,
            size: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue.shade900,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          isDense: false,
          labelText: 'Search ...',
          labelStyle: TextStyle(
            fontFamily: 'Readex Pro',
            color: Colors.white,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue.shade900,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.green.shade900,
        ),
      )
          : Stack(
        children: [
          // The Google Map
          GoogleMap(
            onMapCreated: ((GoogleMapController controller) =>
                _mapController.complete(controller)),
            initialCameraPosition:
            CameraPosition(target: initialPosition, zoom: 15),
            markers: {
              Marker(
                markerId: MarkerId("initialLocation"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow),
                position: initialPosition,
              ),
              Marker(
                markerId: MarkerId("finalLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: finalPosition,
              ),
            },
            polylines: Set<Polyline>.of(polylines.values),
            circles: _circles,
          ),

          // Position the search bar at the top
          Positioned(
            top: 70.0, // Adjust the top position as needed
            left: 15.0,
            right: 15.0,
            child: _buildSearchbar(),
          ),
        ],
      ),
    );
  }
}
