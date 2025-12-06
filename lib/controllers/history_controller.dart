import 'dart:developer';

import 'package:faci_tend/models/attendance_model.dart';
import 'package:faci_tend/services/user_service.dart';
import 'package:faci_tend/utils/helper.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  RxList<AttendanceModel> attendances = RxList<AttendanceModel>([]);

  final UserService _userService = Get.find();

  @override
  void onInit() {
    super.onInit();
    loadAttendances();
  }

  Future<void> loadAttendances() async {
    log('Loading attendance records...');
    try {
      final snapshot = await _userService.loadAttendances();
      attendances.value = snapshot;

      log('Loaded ${attendances.length} attendance records.');
    } catch (e) {
      Helper.showError('Failed to load attendance records: $e');
    }
  }
}
