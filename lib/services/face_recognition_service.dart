import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  Interpreter? _interpreter;
  static const String modelPath = 'assets/models/mobilefacenet.tflite';
  static const int inputSize = 112; // MobileFaceNet input size

  FaceRecognitionService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
    } catch (e) {
      print('Failed to load TFLite model: $e');
    }
  }

  // Pre-processes the image (crop and resize)
  Float32List _preprocessImage(File imageFile, Face face) {
    // Read image as bytes and decode it
    final bytes = imageFile.readAsBytesSync();
    final img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('Could not decode image');
    }

    // Get face bounding box
    final Rect boundingBox = face.boundingBox;

    // Crop the image to the face
    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: boundingBox.left.toInt(),
      y: boundingBox.top.toInt(),
      width: boundingBox.width.toInt(),
      height: boundingBox.height.toInt(),
    );

    // Resize to model input size (112x112)
    final img.Image resizedImage = img.copyResize(
      croppedImage,
      width: inputSize,
      height: inputSize,
    );

    // Normalize the image (0-255 -> -1 to 1 for MobileFaceNet)
    final Float32List imageAsList = Float32List(1 * inputSize * inputSize * 3);
    int pixelIndex = 0;

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        imageAsList[pixelIndex++] = (pixel.r - 127.5) / 128.0; // R
        imageAsList[pixelIndex++] = (pixel.g - 127.5) / 128.0; // G
        imageAsList[pixelIndex++] = (pixel.b - 127.5) / 128.0; // B
      }
    }

    return imageAsList;
  }

  // Runs inference to get the embedding
  List<double> getEmbedding(File imageFile, Face face) {
    if (_interpreter == null) {
      print('Interpreter not loaded');
      return [];
    }

    // 1. Preprocess the image
    final Float32List inputList = _preprocessImage(imageFile, face);

    // Reshape to [1, 112, 112, 3]
    final input = inputList.reshape([1, inputSize, inputSize, 3]);

    // Output is [1, 192] (for MobileFaceNet)
    // The interpreter will fill this list.
    final output = List.filled(1 * 192, 0.0).reshape([1, 192]);

    // 2. Run inference
    try {
      _interpreter!.run(input, output);
    } catch (e) {
      print('Error running TFLite model: $e');
      return [];
    }

    // --- START: THIS IS THE FIX ---

    // 3. Post-process (Cast explicitly)

    // 'output[0]' is of type List<dynamic>
    final List<dynamic> outputList = output[0] as List<dynamic>;

    // Create a new List<double>
    final List<double> embeddingList = [];

    // Iterate and cast each element safely
    for (var e in outputList) {
      embeddingList.add((e as num).toDouble());
    }

    // This now returns a true List<double>, which matches
    // your controller's type and fixes the crash.
    return embeddingList;

    // --- END: NEW FIX ---
  }

  // NEWW
  // Define the maximum distance allowed for a match (e.g., 1.0 or less)
  static const double recognitionThreshold = 1.0;

  /// Calculates the Euclidean distance between two face embeddings.
  double calculateDistance(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw Exception('Embeddings must have the same dimension.');
    }

    double sumOfSquares = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      double difference = embedding1[i] - embedding2[i];
      sumOfSquares += difference * difference;
    }

    // Euclidean distance is the square root of the sum of squares
    return sqrt(sumOfSquares);
  }

  /// Compares a new embedding against the user's saved embedding.
  bool compareFaces(List<double> newEmbedding, List<double>? savedEmbedding) {
    if (savedEmbedding == null || savedEmbedding.isEmpty) {
      // User hasn't enrolled yet
      return false;
    }

    final distance = calculateDistance(newEmbedding, savedEmbedding);

    // Log the distance for debugging
    log('Face Distance: $distance');

    // Return true if the distance is within the allowed threshold
    return distance <= recognitionThreshold;
  }
}
