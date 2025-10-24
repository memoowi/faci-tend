import 'package:flutter/material.dart';

class FaceEnrollPage extends StatelessWidget {
  const FaceEnrollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Enrollment')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text(
                'Next, we need to scan your face to set up your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const Icon(Icons.camera_front_outlined, size: 100),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // TODO: Start camera to scan face
                },
                child: const Text('Start Scan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
