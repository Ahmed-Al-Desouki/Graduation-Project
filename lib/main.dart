import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/presentation/views/doctor_registration_view.dart';
import 'package:graduation_project/features/auth/presentation/views/patient_registration_view.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/patient_registration_view_body.dart';

void main() {
  runApp(const GraduationProject());
}

class GraduationProject extends StatelessWidget {
  const GraduationProject({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: DoctorRegistrationView()),
    );
  }
}
