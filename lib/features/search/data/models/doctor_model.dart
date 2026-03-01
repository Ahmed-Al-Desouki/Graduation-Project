import 'package:flutter/material.dart';

class DoctorModel {
  final String name;
  final String imageUrl;
  final String specialty;
  final String rating;
  final String review;
  final String experience;
  final String distance;

  DoctorModel({
    required this.name,
    required this.imageUrl,
    required this.specialty,
    required this.rating,
    required this.review,
    required this.experience,
    required this.distance,
  });
}

final List<DoctorModel> allDoctors = [
  DoctorModel(
    name: 'Dr. Sandy Chen',
    imageUrl: 'https://i.pravatar.cc/150?img=26',
    specialty: 'Cardiology',

    rating: '4.9',
    review: '(127 reviews)',
    experience: '15 years exp.',
    distance: '0.8 km away',
  ),
  DoctorModel(
    name: 'Dr. Ahmed Hassan',
    imageUrl: 'https://i.pravatar.cc/150?img=12',
    specialty: 'Cardiology',

    rating: '4.7',
    review: '(98 reviews)',
    experience: '12 years exp.',
    distance: '1.5 km away',
  ),

  DoctorModel(
    name: 'Dr. Emily Rodriguez',
    imageUrl: 'https://i.pravatar.cc/150?img=32',
    specialty: 'Orthopedics',

    rating: '4.8',
    review: '(180 reviews)',
    experience: '18 years exp.',
    distance: '1.2 km away',
  ),
  DoctorModel(
    name: 'Dr. Mark Thompson',
    imageUrl: 'https://i.pravatar.cc/150?img=56',
    specialty: 'Orthopedics',

    rating: '4.6',
    review: '(75 reviews)',
    experience: '10 years exp.',
    distance: '2.0 km away',
  ),

  DoctorModel(
    name: 'Dr. Sarah Johnson',
    imageUrl: 'https://i.pravatar.cc/150?img=47',
    specialty: 'Dermatology',

    rating: '4.7',
    review: '(143 reviews)',
    experience: '14 years exp.',
    distance: '0.6 km away',
  ),
  DoctorModel(
    name: 'Dr. Lina Khaled',
    imageUrl: 'https://i.pravatar.cc/150?img=44',
    specialty: 'Dermatology',

    rating: '4.5',
    review: '(89 reviews)',
    experience: '9 years exp.',
    distance: '1.8 km away',
  ),

  DoctorModel(
    name: 'Dr. Olivia Brown',
    imageUrl: 'https://i.pravatar.cc/150?img=27',
    specialty: 'Pediatrics',

    rating: '4.9',
    review: '(210 reviews)',
    experience: '16 years exp.',
    distance: '0.9 km away',
  ),
  DoctorModel(
    name: 'Dr. Natali Lucas',
    imageUrl: 'https://i.pravatar.cc/150?img=19',
    specialty: 'Pediatrics',

    rating: '4.6',
    review: '(95 reviews)',
    experience: '11 years exp.',
    distance: '1.4 km away',
  ),

  DoctorModel(
    name: 'Dr. David Wilson',
    imageUrl: 'https://i.pravatar.cc/150?img=61',
    specialty: 'Neurology',

    rating: '4.8',
    review: '(160 reviews)',
    experience: '20 years exp.',
    distance: '2.5 km away',
  ),
  DoctorModel(
    name: 'Dr. Nour El-Din',
    imageUrl: 'https://i.pravatar.cc/150?img=68',
    specialty: 'Gynecology',

    rating: '4.7',
    review: '(110 reviews)',
    experience: '13 years exp.',
    distance: '1.1 km away',
  ),

  DoctorModel(
    name: 'Dr. James Carter',
    imageUrl: 'https://i.pravatar.cc/150?img=52',
    specialty: 'Dentistry',

    rating: '4.1',
    review: '(88 reviews)',
    experience: '8 years exp.',
    distance: '0.7 km away',
  ),
  DoctorModel(
    name: 'Dr. Rana Mohamed',
    imageUrl: 'https://i.pravatar.cc/150?img=35',
    specialty: 'Plastic Surgery',

    rating: '4.2',
    review: '(70 reviews)',
    experience: '7 years exp.',
    distance: '1.9 km away',
  ),
];
