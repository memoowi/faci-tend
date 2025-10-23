# FaciTend - Face & Location Based Attendance App

built by [**_memoowi_**](https://memoowi.netlify.app/)

FaciTend is a smart attendance application built with Flutter for the Android platform. It leverages on-device AI for face recognition and GPS for location validation to ensure accurate and secure clock-in/clock-out procedures.

## Project Plan

- Design to run on a Firebase "Spark Plan"
- Doesn't rely on Firebase Storage or Cloud Functions
- All Image persistence is handled via Cloudinary
- Face Recognition is performed locally on device

## Features

- **Role-Based Authentication**: Two distinct user roles:
  - **Admin**: Can manage users, view attendance reports, and configure settings.
  - **Basic**: Can clock in/out and view their own attendance history.
  
- **GPS-Verified Attendance**: Captures and validates the user's GPS coordinates during clock-in and clock-out to ensure they are at the correct location.

- **Face Detection**: Uses Firebase MLKit's on-device Face Detection API to identify and frame a user's face before capture.

- **On-Device Face Recognition**: Verifies the user's identity by comparing their live face capture against a stored profile using an on-device AI model (e.g., TensorFlow Lite). This enhances security and works offline.

- **Cloudinary Image Storage**: All attendance-related images are securely uploaded to a Cloudinary account, with the resulting URL stored in Firestore.

## Tech Stack & Architecture

This project is built with a specific set of technologies to meet the "Spark Plan" constraints.

- Frontend: Flutter (Android)

- Backend Services:

  - Firebase Authentication: Handles user sign-up, login, and session management.
  - Cloud Firestore: Used as the primary database for storing:
    - User profiles (including roles and face embedding data).
    - Attendance logs (timestamp, location, Cloudinary image URL).
    - Admin-configured settings (e.g., valid office locations).

- Image Storage:
  - Cloudinary: Used for all image uploads. The app uploads captured images directly to Cloudinary and receives a secure URL in return.

- Machine Learning (On-Device):
  - Firebase MLKit (Face Detection): To detect the presence and bounds of a face in the camera feed.
  - TensorFlow Lite (Face Recognition): An on-device model (e.g., MobileFaceNet) will be used to create face embeddings (a numerical representation of a face) and perform identity verification.

## High-Level Workflow (Clock-In)

1. **Login**: A 'Basic' user logs in via Firebase Auth. The app reads their user data (role, stored face embedding) from Cloud Firestore.

2. **Initiate Clock-In**: User presses the "Clock In" button.

3. **Get Location**: The app fetches the user's current GPS coordinates using the geolocator (or similar) package.

4. **Open Camera**: The camera view is shown to the user.

5. **Detect Face**: MLKit's Face Detection runs on the camera stream. Once a face is clearly detected, the app enables the capture button.

6. **Capture & Recognize**:
   1. The user captures their image.
   2. The captured image is fed into the local TensorFlow Lite model to generate a new embedding.
   3. This new embedding is compared against the user's stored embedding (from Firestore) to verify their identity.

7. Validate: The app checks:
   1. Is the face verified?
   2. Is the GPS location within a valid, predefined area?

8. Upload & Log: If both checks pass:
   1. The captured image is uploaded directly to Cloudinary from the app.
   2. Cloudinary returns an image URL.
   3. A new attendance document is created in Cloud Firestore containing the userId, timestamp, location, and the cloudinaryImageUrl.

## Setup & Installation

1. Clone the repository

```bash
git clone https://github.com/memoowi/faci-tend.git
cd faci-tend
```

2. Set up Firebase:
   1. Create a new Firebase project.
   2. Enable Authentication (e.g., Email/Password).
   3. Enable Cloud Firestore and set up your security rules.
   4. Add an Android app to your Firebase project.
   5. Download the `google-services.json` file and place it in the `android/app/` directory.
   
3. Set up Cloudinary:
   1. Create a Cloudinary account.
   2. Note your `cloud_name`, `api_key`, and `api_secret`.
   3. Create a secure configuration file (e.g., `.env`) to store these credentials. Do not commit these keys to Git.
   
4. Add On-Device Model:
   1. Obtain a pre-trained face recognition model (e.g., a `.tflite` file).
   2. Add the model file to your Flutter `assets/` directory and update `pubspec.yaml`.

5. Install Dependencies:

```bash
flutter pub get
```

6. Run the App

```bash
flutter run
```

## Useful Command for Recreating on Commit Follows

1. **Customizing on Launcher Icons?**
   - Edit the configuration on `flutter_launcher_icons.yaml`
   - You can check the config rules and available params in the package docs in [https://pub.dev/packages/flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
   - Run the package to generate your launcher icons
      ```bash
      dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
      ```

