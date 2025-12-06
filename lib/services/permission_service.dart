import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

// A simple enum to represent our permission state
enum PermissionState { granted, denied, permanentlyDenied, unknown }

class PermissionService extends GetxService {
  // --- Camera Permission ---
  Future<PermissionState> get cameraPermissionStatus async {
    final status = await Permission.camera.status;
    return _convertStatus(status);
  }

  Future<PermissionState> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return _convertStatus(status);
  }

  // --- Location Permission ---
  Future<PermissionState> get locationPermissionStatus async {
    final status = await Permission.location.status;
    return _convertStatus(status);
  }

  Future<PermissionState> requestLocationPermission() async {
    final status = await Permission.location.request();
    return _convertStatus(status);
  }

  // --- Helper to open app settings ---
  Future<void> openAppSetting() async {
    await openAppSettings();
  }

  // --- Private converter ---
  PermissionState _convertStatus(PermissionStatus status) {
    if (status.isGranted) {
      return PermissionState.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionState.permanentlyDenied;
    } else if (status.isDenied) {
      return PermissionState.denied;
    }
    return PermissionState.unknown;
  }
}
