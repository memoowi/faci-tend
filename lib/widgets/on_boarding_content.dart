import 'package:faci_tend/models/on_boarding_info.dart';
import 'package:flutter/material.dart';

class OnBoardingContent extends StatelessWidget {
  final OnBoardingInfo data;

  const OnBoardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 240,
            width: 240,
            child: Image.asset(data.imagePath), // Uncomment when you add images
          ),
          const SizedBox(height: 60),
          Text(
            data.title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            data.subtitle,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
