import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/search/data/models/doctor_model.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/quick_filters.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_header.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  String selectedSpecialty = "All Doctors";

  List<DoctorModel> get filteredDoctors {
    if (selectedSpecialty == "All Doctors") {
      return allDoctors;
    }
    return allDoctors
        .where((doc) => doc.specialty == selectedSpecialty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE8F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        centerTitle: true,
        title: Text(
          "Find Your Doctor",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchHeader(),
            SearchCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PopularSpecialtiesSection(
                selectedSpecialty: selectedSpecialty,
                onSelected: (value) {
                  setState(() {
                    selectedSpecialty = value;
                  });
                },
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuickFilters(),
            ),
            SizedBox(height: 15),
            ...filteredDoctors.map(
              (doctor) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DoctorCard(
                  name: doctor.name,
                  imageUrl: doctor.imageUrl,
                  specialty: doctor.specialty,
                  status: doctor.status,
                  color: doctor.statusColor,
                  rating: doctor.rating,
                  review: doctor.review,
                  experience: doctor.experience,
                  distance: doctor.distance,
                  nextAvailable: doctor.nextAvailable,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_header.dart';

// class SearchView extends StatelessWidget {
//   const SearchView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffE8F7F2),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () {},
//         ),
//         centerTitle: true,
//         title: Text(
//           "Find Your Doctor",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SearchHeader(),
//             SearchCard(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: PopularSpecialtiesSection(),
//             ),
//             SizedBox(height: 15),
//             DoctorCard(
//               name: 'Dr. Sarah Johnson',
//               imageUrl: 'https://i.pravatar.cc/150?img=47',
//               specialty: 'Cardiologist',
//               status: 'Available',
//               color: Colors.green,
//               rating: '4.9',
//               review: '(127 reviews)',
//               experience: '15 years exp.',
//               distance: '0.8 km away',
//               nextAvailable: 'Today, 2:30 PM',
//             ),
//             SizedBox(height: 15),
//             DoctorCard(
//               name: 'Dr. Emily Rodriguez',
//               imageUrl: 'https://i.pravatar.cc/150?img=32',
//               specialty: 'Orthopedic Surgeon',
//               status: 'Busy',
//               color: Colors.orange,
//               rating: '4.8',
//               review: '(180 reviews)',
//               experience: '18 years exp.',
//               distance: '1.2 km away',
//               nextAvailable: 'Tomorrow, 10:00 AM',
//             ),
//             SizedBox(height: 15),
//           ],
//         ),
//       ),
//     );
//   }
// }
