import 'dart:async';
import 'dart:convert';
import 'dart:math';

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

  List<LatLng> currentRoute = [];

  Map<PolylineId, Polyline> polylines = {};
  double BUFFER_ZONE_RADIUS = 500;

  Set<Circle> _circles = {};

  List<LatLng> polylineCoords = [];

  MapApi mapAPI = new MapApi();

  late IOWebSocketChannel _webSocketChannel;
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
    _connectWebSocket();
    getLocationAndUpdate().then((_) => getRoutesWithAlternatives()
        .then((routes) => displayRoutesOnMap(routes)));
  }

  void getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userId = preferences.getString('userId');
  }

  // Connect to web socket

  void _connectWebSocket() {
    _webSocketChannel =
        IOWebSocketChannel.connect('${WEBSOCKETURL}/live-location');
    // IOWebSocketChannel.connect('ws://10.0.2.2:3000/live-location');

    _webSocketChannel.stream.listen((message) {
      var data = jsonDecode(message);
      print(data);
      if (data['latitude'] != null && data['longitude'] != null) {
        setState(() {
          _currentPosition = LatLng(data['latitude'], data['longitude']);
          _updateCircle();
        });

        if (polylineCoords != null && polylineCoords.isNotEmpty) {
          double distance = getDistance(
              LatLng(data['latitude'], data['longitude']), polylineCoords);
          if (distance > BUFFER_ZONE_RADIUS) {
            Fluttertoast.showToast(
                msg:
                "you are out of buffer zone! you are ${distance} km away from the route.");
          } else {
            Fluttertoast.showToast(
                msg:
                "you are inside buffer zone and ${distance} km away from the route.");
          }
        }
      }
    });
  }

  // function for generating buffer zones along the route
  void generateBufferZones(List<LatLng> polylineCoords) {
    const double intervalMeters = 100.0; // distance between circles
    Set<Circle> bufferCircles = {};
    _circles.clear();

    if (polylineCoords.length < 2) return;

    double totalDistance = 0;
    LatLng? lastAdded = polylineCoords.first;
    bufferCircles.add(Circle(
      circleId: CircleId(lastAdded.toString()),
      center: lastAdded,
      radius: BUFFER_ZONE_RADIUS,
      strokeColor: Colors.green.withOpacity(0.6),
      strokeWidth: 2,
      fillColor: Colors.green.withOpacity(0.2),
    ));

    for (int i = 1; i < polylineCoords.length; i++) {
      LatLng start = polylineCoords[i - 1];
      LatLng end = polylineCoords[i];

      double segmentDistance = calculateDistance(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      ) *
          1000; // convert to meters

      double heading = getHeading(start, end);
      double distanceCovered = 0;

      while (distanceCovered + intervalMeters < segmentDistance) {
        distanceCovered += intervalMeters;

        LatLng intermediatePoint = computeOffset(start, distanceCovered, heading);

        bufferCircles.add(Circle(
          circleId: CircleId(intermediatePoint.toString()),
          center: intermediatePoint,
          radius: BUFFER_ZONE_RADIUS,
          strokeColor: Colors.green.withOpacity(0.6),
          strokeWidth: 2,
          fillColor: Colors.green.withOpacity(0.2),
        ));
      }
    }

    setState(() {
      _circles.addAll(bufferCircles);
    });
  }

  double getHeading(LatLng from, LatLng to) {
    double fromLat = radians(from.latitude);
    double fromLng = radians(from.longitude);
    double toLat = radians(to.latitude);
    double toLng = radians(to.longitude);
    double dLng = toLng - fromLng;

    double heading = atan2(
      sin(dLng) * cos(toLat),
      cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(dLng),
    );
    return degrees(heading);
  }

  LatLng computeOffset(LatLng from, double distanceMeters, double headingDegrees) {
    double radius = 6371000; // Earth radius in meters
    double distanceRatio = distanceMeters / radius;
    double bearing = radians(headingDegrees);

    double fromLat = radians(from.latitude);
    double fromLng = radians(from.longitude);

    double toLat = asin(sin(fromLat) * cos(distanceRatio) +
        cos(fromLat) * sin(distanceRatio) * cos(bearing));
    double toLng = fromLng +
        atan2(
            sin(bearing) * sin(distanceRatio) * cos(fromLat),
            cos(distanceRatio) - sin(fromLat) * sin(toLat));

    return LatLng(degrees(toLat), degrees(toLng));
  }

  double radians(double degrees) => degrees * pi / 180;
  double degrees(double radians) => radians * 180 / pi;


// helper funsction for calculating distance between two locations without any unnecsssary api call
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

// function for getting minimum distance between user's current location and all points throught the route.
  double getDistance(LatLng userLocation, List<LatLng> route) {
    // final lat_lng.Distance distance = lat_lng.Distance();

    double totalDistance = double.infinity;

    for (var point in route) {
      double dist = calculateDistance(userLocation.longitude,
          userLocation.latitude, point.longitude, point.latitude);

      if (dist < totalDistance) {
        totalDistance = dist;
      }
    }
    return (totalDistance * 100).round() / 100;
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
    _locationController.changeSettings(
        accuracy: LocationAccuracy.navigation, distanceFilter: 10, interval: 1000);
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
              radius: 3,
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
          color: Colors.white,
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
            getLocationAndUpdate()
                .then((_) => getRoutesWithAlternatives().then((routes) {
              displayRoutesOnMap(routes);
              generateBufferZones(routes[0]);
            }));

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
