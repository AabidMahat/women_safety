import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shake/shake.dart';
import 'package:volume_watcher/volume_watcher.dart';
import 'package:women_safety/utils/SmsTemplate.dart';

class ShakeAndButtonCombo {
  int _shakeCount = 0;
  bool _isReadyForSOS = false;
  Timer? _shakeResetTimer;
  Timer? _sosReadyTimer;
  late  int _volumeListenerId;

  ShakeAndButtonCombo() {
    // Initialize shake detection
    ShakeDetector.autoStart(
      shakeThresholdGravity: 3.0,
      onPhoneShake: _onShakeDetected,
    );

    // Add listener and save the ID for later removal
    _volumeListenerId = VolumeWatcher.addListener(_onVolumeButtonPressed)!;
  }

  void _onShakeDetected() {
    _shakeCount++;

    // Reset shake count if there's a pause in shaking
    _shakeResetTimer?.cancel();
    _shakeResetTimer = Timer(Duration(seconds: 3), () {
      _resetShakeCount();
    });

    if (_shakeCount == 2) {
      _prepareForSOS();
    }
  }

  void _prepareForSOS() {
    Fluttertoast.showToast(msg: "Shake detected twice! Press the volume button within 5 seconds for SOS.");
    _isReadyForSOS = true;

    // Start SOS ready timer to reset after 5 seconds if no button is pressed
    _sosReadyTimer?.cancel();
    _sosReadyTimer = Timer(Duration(seconds: 5), () {
      _resetSOS();
    });
  }

  void _onVolumeButtonPressed(double volume) {
    if (_isReadyForSOS) {
      _triggerSOS();
    } else {
      Fluttertoast.showToast(msg: "Shake twice to activate SOS mode.");
    }
  }

  void _triggerSOS()async {
    Fluttertoast.showToast(msg: "SOS triggered! Taking action...");
    await sendSMS();
    print("SOS triggered!");

    // Reset counters and flags after triggering SOS
    _resetShakeCount();
    _resetSOS();
  }

  void _resetShakeCount() {
    _shakeCount = 0;
    _shakeResetTimer?.cancel();
  }

  void _resetSOS() {
    _isReadyForSOS = false;
    _sosReadyTimer?.cancel();
  }

  void dispose() {
    // Dispose timers and remove listener when done
    _shakeResetTimer?.cancel();
    _sosReadyTimer?.cancel();
    VolumeWatcher.removeListener(_volumeListenerId);
  }
}
