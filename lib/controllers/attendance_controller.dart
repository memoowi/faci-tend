import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:faci_tend/core/routes.dart';
import 'package:faci_tend/services/face_recognition_service.dart';
import 'package:faci_tend/services/permission_service.dart';
import 'package:faci_tend/services/user_service.dart';
import 'package:faci_tend/utils/helper.dart';
import 'package:geolocator/geolocator.dart'; // You will need to install 'geolocator'
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class AttendanceController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final FaceRecognitionService _faceRecService = FaceRecognitionService();
  final PermissionService _permissionService = Get.find<PermissionService>();

  // Configuration for your target attendance location (e.g., school/office)
  static const double TARGET_LATITUDE = 24.467213; // REPLACE WITH ACTUAL LAT
  static const double TARGET_LONGITUDE = 39.602450; // REPLACE WITH ACTUAL LONG
  static const double GEOFENCE_RADIUS_METERS = 2000.0; // Allowed distance

  // Camera and ML setup (similar to enroll controller)
  late final CameraController? cameraController;
  late List<CameraDescription> _cameras;
  CameraDescription? _frontCamera;
  RxBool isCameraInitialized = false.obs;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );

  Rx<PermissionState> cameraPermissionStatus = PermissionState.unknown.obs;
  Rx<PermissionState> locationPermissionStatus = PermissionState.unknown.obs;

  // State
  RxBool isProcessing = false.obs;
  RxString feedbackMessage = 'Checking permissions...'.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCameraAndCheckPermissions();
  }

  @override
  void onClose() {
    isCameraInitialized(false);
    cameraController?.dispose();
    _faceDetector.close();
    super.onClose();
  }

  // --- Initialization and Permissions ---

  Future<void> initializeCameraAndCheckPermissions() async {
    // Check both camera and location permissions
    final cameraStatus = await _permissionService.cameraPermissionStatus;
    cameraPermissionStatus(cameraStatus);
    final locationStatus = await _permissionService.locationPermissionStatus;
    locationPermissionStatus(locationStatus);

    if (locationStatus != PermissionState.granted) {
      feedbackMessage('Location permission is required.');
      return;
    }

    if (cameraStatus != PermissionState.granted) {
      feedbackMessage('Camera permission is required.');
      return;
    }

    // If both granted, initialize camera
    await _initializeCamera();
    feedbackMessage('Ready to Clock In. Frame your face.');
  }

  Future<void> requestPermission() async {
    final locStatus = await _permissionService.requestLocationPermission();
    locationPermissionStatus(locStatus);

    if (locStatus == PermissionState.granted) {
      final camStatus = await _permissionService.requestCameraPermission();
      cameraPermissionStatus(camStatus);

      if (camStatus == PermissionState.granted) {
        await _initializeCamera();
      } else if (camStatus == PermissionState.denied) {
        feedbackMessage(
          'Camera permission was denied. Please grant permission.',
        );
      } else if (camStatus == PermissionState.permanentlyDenied) {
        feedbackMessage(
          'Permission permanently denied. Please open app settings.',
        );
      }
    } else if (locStatus == PermissionState.denied) {
      feedbackMessage(
        'Location permission was denied. Please grant permission.',
      );
    } else if (locStatus == PermissionState.permanentlyDenied) {
      feedbackMessage(
        'Permission permanently denied. Please open app settings.',
      );
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _frontCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      cameraController = CameraController(
        _frontCamera!,
        ResolutionPreset.high, // Medium is usually sufficient for attendance
        enableAudio: false,
      );

      await cameraController?.initialize();
      isCameraInitialized(true);
    } catch (e) {
      feedbackMessage('Failed to initialize camera: $e');
    }
  }

  // --- Attendance Logic ---

  Future<void> clockIn() async {
    if (!isCameraInitialized.value || isProcessing.value) return;

    isProcessing(true);
    feedbackMessage('Verifying location and identity...');

    try {
      // 1. LOCATION CHECK
      feedbackMessage('Getting current location...');
      final Position position = await Geolocator.getCurrentPosition();

      // Check if user is within the geofence
      final double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        TARGET_LATITUDE,
        TARGET_LONGITUDE,
      );

      if (distance > GEOFENCE_RADIUS_METERS) {
        throw Exception(
          'You are ${distance.toStringAsFixed(1)}m away. Must be within ${GEOFENCE_RADIUS_METERS}m of the attendance point.',
        );
      }

      feedbackMessage('Location verified!');

      // 2. FACE CAPTURE & DETECTION (No upload needed)
      feedbackMessage('Capturing image...');
      final XFile imageXFile = await cameraController!.takePicture();
      final File imageFile = File(imageXFile.path);

      feedbackMessage('Detecting face...');
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty || faces.length > 1) {
        throw Exception(
          faces.isEmpty ? 'No face detected.' : 'Multiple faces detected.',
        );
      }

      final Face face = faces.first;

      // 3. GET & COMPARE EMBEDDING
      feedbackMessage('Comparing face profile...');

      final List<double> newEmbedding = _faceRecService.getEmbedding(
        imageFile,
        face,
      );
      // check type of newEmbedding
      log('newEmbedding type: ${newEmbedding.runtimeType}');
      if (newEmbedding.isEmpty) {
        throw Exception('Failed to process face profile.');
      }

      // Get the saved embedding from the currently logged-in user
      final savedEmbedding = _userService.firestoreUser.value?.faceEmbedding;

      final List<double> savedEmbeddingListDouble = [];

      if (savedEmbedding != null) {
        for (var i = 0; i < savedEmbedding.length; i += 1) {
          savedEmbeddingListDouble.add(savedEmbedding[i].toDouble());
        }
      }

      final bool isMatch = _faceRecService.compareFaces(
        newEmbedding,
        savedEmbeddingListDouble,
      );

      if (!isMatch) {
        throw Exception('Face recognition failed. Identity mismatch.');
      }

      feedbackMessage('Identity verified! Clocking you in...');

      // 4. FINAL STEP: CLOCK IN RECORD
      await _userService.recordAttendance(position, distance);
      Get.offAllNamed(AppRouter.home);
    } catch (e) {
      log('Clock In Failed: $e');
      Helper.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isProcessing(false);
      feedbackMessage('Frame your face in the oval');
    }
  }
}
