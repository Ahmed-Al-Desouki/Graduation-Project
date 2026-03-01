import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/search/data/models/doctor_model.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_header.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  // تأكدنا إن القيم ليها Default values مش Null
  String selectedSpecialty = "All Specialties";
  String searchQuery = "";

  List<DoctorModel> get filteredDoctors {
    // نستخدم لستة الدكاترة الأصلية
    return allDoctors.where((doc) {
      // 1. فلترة التخصص (تأمين ضد الـ Null)
      final docSpecialty = doc.specialty;
      bool matchesSpecialty =
          (selectedSpecialty == "All Specialties") ||
          docSpecialty == selectedSpecialty;

      // 2. فلترة البحث
      bool matchesQuery =
          searchQuery.isEmpty ||
          doc.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          docSpecialty.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesSpecialty && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE8F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchHeader(),
            SearchCard(
              searchQuery: searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  searchQuery = value;
                  // searchQuery = value ?? ""; // تأمين
                });
              },
              selectedSpecialty: selectedSpecialty,
              onSpecialtyChanged: (value) {
                setState(() {
                  selectedSpecialty = value;
                  // selectedSpecialty = value ?? "All Doctors"; // تأمين
                });
              },
            ),
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
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Available Doctors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),

            if (filteredDoctors.isEmpty)
              Padding(
                padding: EdgeInsets.all(40.h),
                child: Row(
                  children: [
                    Spacer(flex: 1),
                    const Text(
                      "No doctors found",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DoctorCard(
                      name: doctor.name,
                      imageUrl: doctor.imageUrl,
                      specialty: doctor.specialty,
                      rating: doctor.rating,
                      review: doctor.review,
                      experience: doctor.experience,
                      distance: doctor.distance,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
//----------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:graduation_project/features/search/data/models/doctor_model.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/quick_filters.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_header.dart';

// class SearchView extends StatefulWidget {
//   const SearchView({super.key});

//   @override
//   State<SearchView> createState() => _SearchViewState();
// }

// class _SearchViewState extends State<SearchView> {
//   String selectedSpecialty = "All Doctors";

//   List<DoctorModel> get filteredDoctors {
//     if (selectedSpecialty == "All Doctors") {
//       return allDoctors;
//     }
//     return allDoctors
//         .where((doc) => doc.specialty == selectedSpecialty)
//         .toList();
//   }

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
//               child: PopularSpecialtiesSection(
//                 selectedSpecialty: selectedSpecialty,
//                 onSelected: (value) {
//                   setState(() {
//                     selectedSpecialty = value;
//                   });
//                 },
//               ),
//             ),
//             SizedBox(height: 15),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: QuickFilters(),
//             ),
//             SizedBox(height: 15),
//             ...filteredDoctors.map(
//               (doctor) => Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: DoctorCard(
//                   name: doctor.name,
//                   imageUrl: doctor.imageUrl,
//                   specialty: doctor.specialty,
//                   status: doctor.status,
//                   color: doctor.statusColor,
//                   rating: doctor.rating,
//                   review: doctor.review,
//                   experience: doctor.experience,
//                   distance: doctor.distance,
//                   nextAvailable: doctor.nextAvailable,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:graduation_project/features/search/data/models/doctor_model.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/specialty_bottom_sheet_for_search.dart';

// class SearchView extends StatefulWidget {
//   const SearchView({super.key});

//   @override
//   State<SearchView> createState() => _SearchViewState();
// }

// class _SearchViewState extends State<SearchView> {
//   String searchQuery = "";
//   String selectedDropdownSpecialty = "All Specialties";
//   String selectedPopularSpecialty = "All Doctors";

//   late List<DoctorModel> filteredDoctors;

//   final List<DoctorModel> allDoctors = [
//     DoctorModel(
//       name: 'Dr. Sarah Johnson',
//       imageUrl: 'https://i.pravatar.cc/150?img=47',
//       specialty: 'Cardiology',
//       status: 'Available',
//       statusColor: Colors.green,
//       rating: '4.9',
//       review: '(127 reviews)',
//       experience: '15 years exp.',
//       distance: '0.8 km away',
//       nextAvailable: 'Today, 2:30 PM',
//     ),
//     DoctorModel(
//       name: 'Dr. Michael Chen',
//       imageUrl: 'https://i.pravatar.cc/150?img=32',
//       specialty: 'Dermatology',
//       status: 'Busy',
//       statusColor: Colors.orange,
//       rating: '4.7',
//       review: '(89 reviews)',
//       experience: '12 years exp.',
//       distance: '1.2 km away',
//       nextAvailable: 'Tomorrow, 10:00 AM',
//     ),
//     DoctorModel(
//       name: 'Dr. Emily Rodriguez',
//       imageUrl: 'https://i.pravatar.cc/150?img=12',
//       specialty: 'Orthopedics',
//       status: 'Available',
//       statusColor: Colors.green,
//       rating: '4.8',
//       review: '(180 reviews)',
//       experience: '18 years exp.',
//       distance: '1.5 km away',
//       nextAvailable: 'Today, 5:00 PM',
//     ),
//     DoctorModel(
//       name: 'Dr. Daniel Smith',
//       imageUrl: 'https://i.pravatar.cc/150?img=65',
//       specialty: 'Pediatrics',
//       status: 'Available',
//       statusColor: Colors.green,
//       rating: '4.6',
//       review: '(95 reviews)',
//       experience: '10 years exp.',
//       distance: '0.9 km away',
//       nextAvailable: 'Today, 4:30 PM',
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     filteredDoctors = allDoctors;
//   }

//   void applyFilters() {
//     setState(() {
//       filteredDoctors = allDoctors.where((doctor) {
//         final matchesSearch = searchQuery.isEmpty ||
//             doctor.name
//                 .toLowerCase()
//                 .contains(searchQuery.toLowerCase());

//         final matchesDropdownSpecialty =
//             selectedDropdownSpecialty == "All Specialties" ||
//                 doctor.specialty == selectedDropdownSpecialty;

//         final matchesPopularSpecialty =
//             selectedPopularSpecialty == "All Doctors" ||
//                 doctor.specialty == selectedPopularSpecialty;

//         return matchesSearch &&
//             matchesDropdownSpecialty &&
//             matchesPopularSpecialty;
//       }).toList();
//     });
//   }

//   void _openSpecialtySheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return SpecialtyBottomSheetForSearch(
//           onSelected: (value) {
//             setState(() {
//               selectedDropdownSpecialty = value;
//             });
//             applyFilters();
//             Navigator.pop(context);
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffE8F7F2),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Find Your Doctor",
//           style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             /// 🔍 Search Bar
//             SearchCard(
//               selectedSpecialty: selectedDropdownSpecialty,
//               onSpecialtyTap: _openSpecialtySheet,
//               onSearchChanged: (value) {
//                 searchQuery = value;
//                 applyFilters();
//               },
//             ),

//             const SizedBox(height: 10),

//             /// 🏥 Popular Specialties
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16),
//               child: PopularSpecialtiesSection(
//                 selectedSpecialty:
//                     selectedPopularSpecialty,
//                 onSelected: (value) {
//                   selectedPopularSpecialty = value;
//                   applyFilters();
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// 👨‍⚕️ Doctor Cards (Results)
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 12),
//               child: filteredDoctors.isEmpty
//                   ? Column(
//                       children: const [
//                         SizedBox(height: 40),
//                         Icon(Icons.search_off,
//                             size: 50,
//                             color: Colors.grey),
//                         SizedBox(height: 10),
//                         Text(
//                           "No doctors found",
//                           style: TextStyle(
//                               color: Colors.grey),
//                         ),
//                       ],
//                     )
//                   : Column(
//                       children:
//                           filteredDoctors.map((doctor) {
//                         return Padding(
//                           padding:
//                               const EdgeInsets.only(
//                                   bottom: 15),
//                           child: DoctorCard(
//                             name: doctor.name,
//                             imageUrl:
//                                 doctor.imageUrl,
//                             specialty:
//                                 doctor.specialty,
//                             status: doctor.status,
//                             color:
//                                 doctor.statusColor,
//                             rating:
//                                 doctor.rating,
//                             review:
//                                 doctor.review,
//                             experience:
//                                 doctor.experience,
//                             distance:
//                                 doctor.distance,
//                             nextAvailable:
//                                 doctor.nextAvailable,
//                           ),
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//------------------------------------------------------------------------------
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
