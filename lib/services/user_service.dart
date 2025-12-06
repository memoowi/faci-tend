import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faci_tend/core/routes.dart';
import 'package:faci_tend/models/user_model.dart';
import 'package:faci_tend/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class UserService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<UserModel> firestoreUser = Rxn<UserModel>();

  bool get isLoggedIn => firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _onAuthChanged);
  }

  // --- REPLACE YOUR METHOD WITH THIS ---
  Future<void> _onAuthChanged(User? user) async {
    // This function handles all app start and auth logic
    final box = GetStorage();
    final bool isFirstTime = box.read('isFirstTime') ?? true;

    if (isFirstTime) {
      // 1. First time user -> Go to Onboarding
      Get.offAllNamed(AppRouter.onBoarding);
    } else if (user == null) {
      // 2. Not first time, but logged out -> Go to Login
      Get.offAllNamed(AppRouter.login);
    } else {
      // 3. Not first time, and logged in
      // We MUST load their data first to see if they are fully enrolled.
      await _loadFirestoreUser(user.uid);

      if (firestoreUser.value == null) {
        // This is an error state (Auth user exists, but no Firestore doc)
        // Safest bet is to log them out and send to login.
        Get.offAllNamed(AppRouter.login);
      } else {
        // --- THIS IS THE FIX ---
        // User data IS loaded. NOW we check enrollment.
        if (firestoreUser.value!.faceEmbedding == null) {
          // 3a. Logged in, but NO face -> Force enrollment
          Get.offAllNamed(AppRouter.faceEnroll);
        } else {
          // 3b. Logged in, AND face exists -> Go to Home
          Get.offAllNamed(AppRouter.home);
        }
        // --- END FIX ---
      }
    }

    // After navigation is decided, remove the native splash screen
    FlutterNativeSplash.remove();
  }

  Future<void> _loadFirestoreUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        firestoreUser.value = UserModel.fromMap(doc.data()!);
      } else {
        throw 'User data not found. Please contact support.';
      }
    } catch (e) {
      await _auth.signOut();
      Helper.showError('Error loading user data: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> saveFaceEmbedding(
    List<double> embedding,
    String imageUrl,
  ) async {
    if (firebaseUser.value == null) {
      Get.snackbar('Error', 'You are not logged in.');
      return;
    }

    final uid = firebaseUser.value!.uid;

    try {
      // 1. Update the document in Firestore
      await _firestore.collection('users').doc(uid).update({
        'faceEmbedding': embedding,
        'faceImageUrl': imageUrl,
      });

      // 2. Update the local user model in our controller
      if (firestoreUser.value != null) {
        // Create a new model instance with the updated data
        firestoreUser.value = UserModel(
          uid: firestoreUser.value!.uid,
          email: firestoreUser.value!.email,
          displayName: firestoreUser.value!.displayName,
          role: firestoreUser.value!.role,
          createdAt: firestoreUser.value!.createdAt,
          faceEmbedding: embedding, // Add the new embedding
          faceImageUrl: imageUrl,
        );
      }

      // 3. Navigate to home after successful enrollment
      Get.snackbar(
        'Success',
        'Face enrollment complete! Welcome.',
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed(AppRouter.home);
    } catch (e) {
      Get.snackbar('Error', 'Could not save face data: $e');
    }
  }

  Future<void> recordAttendance(Position position, double distance) async {
    if (firebaseUser.value == null) {
      Get.snackbar('Error', 'You are not logged in.');
      return;
    }

    final uid = firebaseUser.value!.uid;

    try {
      await _firestore.collection('attendance').add({
        'userId': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'clock_in', // You can expand this for clock-out logic
        'location': GeoPoint(position.latitude, position.longitude),
        'distanceToTargetMeters': distance,
      });

      Get.snackbar(
        'Success! 🎉',
        'You have successfully clocked in.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Helper.showError('Failed to save attendance record: $e');
    }
  }
}
