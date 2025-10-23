import 'package:faci_tend/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page'), actions: [ThemeToggle()]),
      body: const Center(child: Text('Home Page')),
    );
  }
}
