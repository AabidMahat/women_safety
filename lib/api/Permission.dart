import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class PermissionApi {
  Position? _currentPosition;

  Future<Position?> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Location services are disabled.");
      return null;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permission is denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permission is denied forever.");
      return null;
    }

    // If permissions are granted, get the current position
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
      Fluttertoast.showToast(msg: "Location fetched successfully.");
      return _currentPosition;
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get current location: $e");
      return null;
    }
  }
}
