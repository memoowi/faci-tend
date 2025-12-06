import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faci_tend/core/routes.dart';
import 'package:faci_tend/models/user_model.dart';
import 'package:faci_tend/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observableesssss
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // Text Controllers for global duhh
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Text Controllers for Register only duhh wkwkwk
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> loginUser() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    isLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // _clearControllers();
      Get.offAllNamed(AppRouter.home);
    } on FirebaseAuthException catch (e) {
      Helper.showError(e.message ?? 'Login failed');
    } finally {
      isLoading(false);
    }
  }

  Future<void> registerUser() async {
    if (!registerFormKey.currentState!.validate()) {
      return;
    }

    isLoading(true);
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        await _createUserDocument(
          userCredential.user!,
          nameController.text.trim(),
        );
      }

      // _clearControllers();
      Get.offAllNamed(AppRouter.faceEnroll);
    } on FirebaseAuthException catch (e) {
      Helper.showError(e.message ?? 'Registration failed');
    } finally {
      isLoading(false);
    }
  }

  // Helppperrrrr

  Future<void> _createUserDocument(User user, String displayName) async {
    final newUser = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      createdAt: Timestamp.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
  }

  // void _clearControllers() {
  //   emailController.clear();
  //   passwordController.clear();
  //   nameController.clear();
  //   confirmPasswordController.clear();
  // }
}
