import 'package:flutter/material.dart';

class PatientHomeView extends StatelessWidget {
  const PatientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Patient Home')),
      body: Center(child: Text('Welcome Patient 🧑‍🦱')),
    );
  }
}
