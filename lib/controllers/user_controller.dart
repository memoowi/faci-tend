import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faci_tend/core/routes.dart';
import 'package:faci_tend/models/user_model.dart';
import 'package:faci_tend/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class UserController extends GetxService {
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

  Future<void> _onAuthChanged(User? user) async {
    final box = GetStorage();
    final bool isFirstTime = box.read('isFirstTime') ?? true;

    if (isFirstTime) {
      Get.offAllNamed(AppRouter.onBoarding);
    } else if (user == null) {
      Get.offAllNamed(AppRouter.login);
    } else {
      await _loadFirestoreUser(user.uid);
      Get.offAllNamed(AppRouter.home);
    }

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
}
