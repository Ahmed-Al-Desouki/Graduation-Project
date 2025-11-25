import 'package:flutter/material.dart';

class AppointmentModel {
  final String doctorName;
  final String specialty;
  final String date;
  final String title;
  final String description;
  final String duration;
  final String location;
  final String imagePath;
  final Color cardColor;

  AppointmentModel({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.title,
    required this.description,
    required this.duration,
    required this.location,
    required this.imagePath,
    required this.cardColor,
  });
}
