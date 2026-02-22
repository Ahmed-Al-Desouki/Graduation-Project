import 'package:flutter/material.dart';

class DoctorModel {
  final String name;
  final String imageUrl;
  final String specialty;
  final String status;
  final Color statusColor;
  final String rating;
  final String review;
  final String experience;
  final String distance;
  final String nextAvailable;

  DoctorModel({
    required this.name,
    required this.imageUrl,
    required this.specialty,
    required this.status,
    required this.statusColor,
    required this.rating,
    required this.review,
    required this.experience,
    required this.distance,
    required this.nextAvailable,
  });
}

final List<DoctorModel> allDoctors = [
  DoctorModel(
    name: 'Dr. Sandy Chen',
    imageUrl: 'https://i.pravatar.cc/150?img=26',
    specialty: 'Cardiology',
    status: 'Available',
    statusColor: Colors.green,
    rating: '4.9',
    review: '(127 reviews)',
    experience: '15 years exp.',
    distance: '0.8 km away',
    nextAvailable: 'Today, 2:30 PM',
  ),
  DoctorModel(
    name: 'Dr. Ahmed Hassan',
    imageUrl: 'https://i.pravatar.cc/150?img=12',
    specialty: 'Cardiology',
    status: 'Busy',
    statusColor: Colors.orange,
    rating: '4.7',
    review: '(98 reviews)',
    experience: '12 years exp.',
    distance: '1.5 km away',
    nextAvailable: 'Tomorrow, 11:00 AM',
  ),

  DoctorModel(
    name: 'Dr. Emily Rodriguez',
    imageUrl: 'https://i.pravatar.cc/150?img=32',
    specialty: 'Orthopedics',
    status: 'Busy',
    statusColor: Colors.orange,
    rating: '4.8',
    review: '(180 reviews)',
    experience: '18 years exp.',
    distance: '1.2 km away',
    nextAvailable: 'Tomorrow, 10:00 AM',
  ),
  DoctorModel(
    name: 'Dr. Mark Thompson',
    imageUrl: 'https://i.pravatar.cc/150?img=56',
    specialty: 'Orthopedics',
    status: 'Available',
    statusColor: Colors.green,
    rating: '4.6',
    review: '(75 reviews)',
    experience: '10 years exp.',
    distance: '2.0 km away',
    nextAvailable: 'Today, 5:00 PM',
  ),

  DoctorModel(
    
    name: 'Dr. Sarah Johnson',
    imageUrl: 'https://i.pravatar.cc/150?img=47',
    specialty: 'Dermatology',
    status: 'Available',
    statusColor: Colors.green,
    rating: '4.7',
    review: '(143 reviews)',
    experience: '14 years exp.',
    distance: '0.6 km away',
    nextAvailable: 'Today, 4:00 PM',
  ),
  DoctorModel(
    name: 'Dr. Lina Khaled',
    imageUrl: 'https://i.pravatar.cc/150?img=44',
    specialty: 'Dermatology',
    status: 'Busy',
    statusColor: Colors.orange,
    rating: '4.5',
    review: '(89 reviews)',
    experience: '9 years exp.',
    distance: '1.8 km away',
    nextAvailable: 'Tomorrow, 1:30 PM',
  ),

  DoctorModel(
    name: 'Dr. Olivia Brown',
    imageUrl: 'https://i.pravatar.cc/150?img=27',
    specialty: 'Pediatrics',
    status: 'Available',
    statusColor: Colors.green,
    rating: '4.9',
    review: '(210 reviews)',
    experience: '16 years exp.',
    distance: '0.9 km away',
    nextAvailable: 'Today, 3:00 PM',
  ),
  DoctorModel(
    name: 'Dr. Natali Lucas',
    imageUrl: 'https://i.pravatar.cc/150?img=19',
    specialty: 'Pediatrics',
    status: 'Available',
    statusColor: Colors.green,
    rating: '4.6',
    review: '(95 reviews)',
    experience: '11 years exp.',
    distance: '1.4 km away',
    nextAvailable: 'Today, 6:00 PM',
  ),

  DoctorModel(
    name: 'Dr. David Wilson',
    imageUrl: 'https://i.pravatar.cc/150?img=61',
    specialty: 'Neurology',
    status: 'Busy',
    statusColor: Colors.orange,
    rating: '4.8',
    review: '(160 reviews)',
    experience: '20 years exp.',
    distance: '2.5 km away',
    nextAvailable: 'Tomorrow, 9:30 AM',
  ),
  DoctorModel(
    name: 'Dr. Nour El-Din',
    imageUrl: 'https://i.pravatar.cc/150?img=68',
    specialty: 'Gynecology',
    status: 'Available',
    statusColor: Colors.green,
    rating: '4.7',
    review: '(110 reviews)',
    experience: '13 years exp.',
    distance: '1.1 km away',
    nextAvailable: 'Today, 7:00 PM',
  ),

  DoctorModel(
    name: 'Dr. James Carter',
    imageUrl: 'https://i.pravatar.cc/150?img=52',
    specialty: 'Dentistry',
    status: 'Available',
    statusColor: Colors.green,
    rating: '4.6',
    review: '(88 reviews)',
    experience: '8 years exp.',
    distance: '0.7 km away',
    nextAvailable: 'Today, 5:30 PM',
  ),
  DoctorModel(
    name: 'Dr. Rana Mohamed',
    imageUrl: 'https://i.pravatar.cc/150?img=35',
    specialty: 'Dentistry',
    status: 'Busy',
    statusColor: Colors.orange,
    rating: '4.5',
    review: '(70 reviews)',
    experience: '7 years exp.',
    distance: '1.9 km away',
    nextAvailable: 'Tomorrow, 12:00 PM',
  ),
];
