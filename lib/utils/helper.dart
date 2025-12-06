import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  static onTapOutside(event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withAlpha(180),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static String formattedTime(DateTime dateTime) {
    final formattedTime = DateFormat('MMM dd - HH:mm:ss a').format(dateTime);

    return formattedTime;
  }

  static Future<void> openMap(GeoPoint location) async {
    final lat = location.latitude;
    final lng = location.longitude;

    // 1. Create a geo URI (preferred for device compatibility)
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng(Attendance Location)');

    // 2. Try launching the geo URI
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      // 3. Fallback to a web-based Google Maps URL
      final googleMapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );

      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not open any map application for $lat, $lng');
      }
    }
  }
}
