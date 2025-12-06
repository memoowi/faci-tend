import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:faci_tend/services/cloudinary_service.dart';
import 'package:faci_tend/services/face_recognition_service.dart';
import 'package:faci_tend/services/permission_service.dart';
import 'package:faci_tend/services/user_service.dart';
import 'package:faci_tend/utils/helper.dart';
import 'package:get/get.dart';

// These are the correct imports for your pubspec.yaml
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceEnrollController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final FaceRecognitionService _faceRecService = FaceRecognitionService();
  final PermissionService _permissionService = Get.find<PermissionService>();
  final CloudinaryService _cloudinaryService = Get.find<CloudinaryService>();

  // Camera
  late final CameraController cameraController;
  late List<CameraDescription> _cameras;
  CameraDescription? _frontCamera;
  RxBool isCameraInitialized = false.obs;

  Rx<PermissionState> cameraPermissionStatus = PermissionState.unknown.obs;

  // ML Kit Face Detector
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );

  // State
  RxBool isProcessing = false.obs;
  RxString feedbackMessage = 'Frame your face in the oval'.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermissionAndInitialize();
  }

  @override
  void onClose() {
    isCameraInitialized(false);
    // Check if cameraController was ever initialized before disposing
    cameraController.dispose();
    _faceDetector.close();
    super.onClose();
  }

  // --- NEW METHOD ---
  Future<void> checkPermissionAndInitialize() async {
    final status = await _permissionService.cameraPermissionStatus;
    cameraPermissionStatus(status);

    if (status == PermissionState.granted) {
      // If we have permission, start initializing
      await _initializeCamera();
    } else {
      // If not, update feedback
      feedbackMessage('Camera permission is required to enroll.');
    }
  }

  // --- NEW METHOD ---
  Future<void> requestPermission() async {
    final status = await _permissionService.requestCameraPermission();
    cameraPermissionStatus(status);

    if (status == PermissionState.granted) {
      await _initializeCamera();
    } else if (status == PermissionState.denied) {
      feedbackMessage('Camera permission was denied. Please grant permission.');
    } else if (status == PermissionState.permanentlyDenied) {
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
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController.initialize();
      isCameraInitialized(true);

      feedbackMessage('Position your face in the oval');
    } catch (e) {
      feedbackMessage('Failed to initialize camera: $e');
    }
  }

  // --- THIS IS THE NEW SIMPLIFIED LOGIC ---
  Future<void> captureAndEnrollFace() async {
    if (!isCameraInitialized.value) return;

    isProcessing(true);
    feedbackMessage('Processing...');

    try {
      // 1. CAPTURE
      final XFile imageXFile = await cameraController.takePicture();
      final File imageFile = File(imageXFile.path);

      // 2. DETECT FACE (from the captured file)
      feedbackMessage('Detecting face...');
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        throw Exception('No face detected. Please try again.');
      }

      if (faces.length > 1) {
        throw Exception(
          'Multiple faces detected. Please make sure only one face is visible.',
        );
      }

      final Face face = faces.first; // We only care about the first face

      // 3. GET EMBEDDING (Service will crop, resize, and run TFLite)
      feedbackMessage('Creating face profile...');

      final List<double> embedding = _faceRecService.getEmbedding(
        imageFile,
        face,
      );

      if (embedding.isEmpty) {
        throw Exception('Failed to create face profile.');
      }

      final String imageUrl = await _cloudinaryService.uploadImage(imageFile);

      // 4. SAVE
      feedbackMessage('Saving profile...');
      await _userService.saveFaceEmbedding(embedding, imageUrl);
      // Navigation is handled by the service on success
    } catch (e) {
      log(e.toString());
      Helper.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isProcessing(false);
      feedbackMessage('Frame your face in the oval');
    }
  }
}
