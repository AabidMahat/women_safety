import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionApi {
  Position? _currentPosition;

  Future<Position?> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
          msg: "Location services are disabled. Please turn on location");
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
      Fluttertoast.showToast(
          msg:
              "Location permission is denied forever. Please enable it in settings.");
      await Geolocator.openAppSettings();
      return null;
    }

    // If permissions are granted, get the current position
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
      return _currentPosition;
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get current location: $e");
      return null;
    }
  }

  Future<void> requestPhoneStatePermission() async {
    final status = await Permission.phone.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: 'Phone state permission is not granted');
    }
  }

  Future<void> requestRecordAuidoPermission()async{
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: 'Audio state permission is not granted');
    }
  }

  Future<void> requestSmsPermission() async {
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: 'Sms permission is not granted');
    }
  }

  Future<void> requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: 'Storage permission is not granted');
    }
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Fluttertoast.showToast(msg: 'Camera permission is not granted');
    }
  }
}
