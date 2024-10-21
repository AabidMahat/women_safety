import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety/home_screen.dart';
import '../Database/Database.dart';
import '../api/FeedbackApi.dart';
import '../api/mapApi.dart';
import 'AddFeedback.dart';
import 'FeedbacRevews.dart';
import 'FeedbackForm.dart';

class FeedbackScreen extends StatefulWidget {
  final LatLng currentPosition;

  const FeedbackScreen({required this.currentPosition, super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  List<FeedbackData> feedbackList = [];
  final Completer<GoogleMapController> _mapController =
  Completer<GoogleMapController>();

  MapType _currentMapType = MapType.hybrid;

  FeedbackApi feedbackApi = FeedbackApi();
  MapApi googleMapAPI = MapApi();

  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = CameraPosition(
      target: LatLng(
          widget.currentPosition.latitude, widget.currentPosition.longitude),
      zoom: 17,
    );
    _fetchFeedbackData();
    _listenToFeedbackStream();
  }

  void _listenToFeedbackStream() {
    feedbackApi.feedbackStream.listen((newFeedback) {
      setState(() {
        feedbackList.add(newFeedback);
      });
      _updateMarkersAndCircles();

    });
  }

  void _fetchFeedbackData() async {
    await feedbackApi.getAllFeedback();
    setState(() {
      feedbackList = feedbackApi
          .getFeedBackData()
          .where((newFeedback) => !feedbackList
          .any((existingFeedback) => existingFeedback.id == newFeedback.id))
          .toList();
      _updateMarkersAndCircles();
    });
  }

  void _onMapTap(LatLng position) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddFeedback(position: LatLng(position.latitude, position.longitude))));
  }

  void _updateMarkersAndCircles() {
    _showMarkers(feedbackList);
    _renderDomeOnMap();
  }

  void _showMarkers(List<FeedbackData> feedbackList) async {
    Set<Marker> newMarkers = {};
    for (var feedback in feedbackList) {
      Color markerColor = _getMarkerColor(feedback.category);

      String placeName = await googleMapAPI.getPlace(
          feedback.location['latitude']!, feedback.location['longitude']!);

      newMarkers.add(Marker(
        markerId: MarkerId(feedback.id),
        infoWindow: InfoWindow(
          title: placeName, // Show the place name in the InfoWindow
          snippet: feedback.comments,
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FeedbackReview(
                      feedback: feedback, feedbackList: feedbackList)));
        },
        position: LatLng(
            feedback.location['latitude']!, feedback.location['longitude']!),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(markerColor)),
      ));
    }
    setState(() {
      _markers = newMarkers;
    });
  }

  Color _getMarkerColor(String category) {
    switch (category) {
      case 'Dangerous':
        return Colors.red;
      case 'Suspicious':
        return Colors.yellow;
      case 'Safe':
      default:
        return Colors.green;
    }
  }

  double _getMarkerHue(Color color) {
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    if (color == Colors.yellow) return BitmapDescriptor.hueYellow;
    return BitmapDescriptor.hueGreen;
  }

  void _renderDomeOnMap() {
    Set<Circle> newCircles = {};
    Map<String, int> dangerCount = {};
    Map<String, int> suspiciousCount = {};
    Map<String, int> safeCount = {};

    for (var feedback in feedbackList) {
      String locationKey =
          '${feedback.location['latitude']!},${feedback.location['longitude']!}';

      if (feedback.category == 'Dangerous') {
        dangerCount[locationKey] = (dangerCount[locationKey] ?? 0) + 1;
      } else if (feedback.category == 'Suspicious') {
        suspiciousCount[locationKey] = (suspiciousCount[locationKey] ?? 0) + 1;
      } else if (feedback.category == 'Safe') {
        safeCount[locationKey] = (safeCount[locationKey] ?? 0) + 1;
      }
    }

    Set<String> allLocations = {
      ...dangerCount.keys,
      ...suspiciousCount.keys,
      ...safeCount.keys
    };

    for (var location in allLocations) {
      int danger = dangerCount[location] ?? 0;
      int suspicious = suspiciousCount[location] ?? 0;
      int safe = safeCount[location] ?? 0;
      Color domeColor = _calculateDomeColor(danger, suspicious, safe);

      newCircles.add(Circle(
        circleId: CircleId('$location'),
        center: LatLng(
          double.parse(location.split(",")[0]),
          double.parse(location.split(',')[1]),
        ),
        radius: (danger + suspicious + safe) * 4.0,
        fillColor: domeColor.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: domeColor,
      ));
    }

    setState(() {
      _circles = newCircles;
    });
  }

  Color _calculateDomeColor(int dangerCount, int suspiciousCount, int safeCount) {
    int dangerIntensity = (dangerCount * 50).clamp(0, 255);
    int suspiciousIntensity = (suspiciousCount * 50).clamp(0, 255);
    int safeIntensity = (safeCount * 50).clamp(0, 255);

    if (dangerCount >= suspiciousCount && dangerCount >= safeCount) {
      return Color.fromARGB(255, dangerIntensity, 0, 0);
    } else if (suspiciousCount >= dangerCount && suspiciousCount >= safeCount) {
      return Color.fromARGB(255, suspiciousIntensity, suspiciousIntensity, 0);
    } else {
      return Color.fromARGB(255, 0, safeIntensity, 0);
    }
  }

  @override
  void dispose() {
    feedbackApi.closeWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        body: GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          mapType: _currentMapType,
          onTap: _onMapTap,
          markers: _markers,
          circles: _circles,
        ),
      ),
    );
  }
}
