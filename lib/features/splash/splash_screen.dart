import 'package:flutter/material.dart';
import 'package:graduation_project/features/splash/splash_body.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashBody(),
    );
  }
}