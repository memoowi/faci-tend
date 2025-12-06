import 'dart:io';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class CloudinaryService extends GetxService {
  late final Cloudinary _cloudinary;

  @override
  void onInit() {
    super.onInit();
    // 1. Initialize the Cloudinary instance for UNsigned (client-side) uploads
    _cloudinary = Cloudinary.unsignedConfig(
      cloudName: dotenv.get('CLOUDINARY_CLOUD_NAME'),
    );
  }

  /// Uploads a file to Cloudinary using the package's unsigned upload method.
  Future<String> uploadImage(File imageFile) async {
    try {
      // 2. Perform the Unsigned Upload
      final response = await _cloudinary.unsignedUpload(
        file: imageFile.path,
        uploadPreset: dotenv.get('CLOUDINARY_UPLOAD_PRESET'),
        resourceType: CloudinaryResourceType.image,
        folder: 'faci_tend_enrollment',
        fileName: 'selfie_${DateTime.now().millisecondsSinceEpoch}',
      );

      // 3. Handle the successful response
      if (response.isResultOk) {
        return response.secureUrl!;
      } else {
        // Handle failed uploads (e.g., preset error, size limit)
        throw Exception(
          'Cloudinary upload failed: ${response.error ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      // Re-throw the exception for the controller to catch
      throw Exception('Image upload error: $e');
    }
  }
}
