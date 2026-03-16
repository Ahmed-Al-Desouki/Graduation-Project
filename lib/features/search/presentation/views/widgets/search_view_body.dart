import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constant.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/doctors_list_view.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/search_header.dart';

class SearchViewBody extends StatefulWidget {
  const SearchViewBody({super.key});

  @override
  State<SearchViewBody> createState() => _SearchViewBodyState();
}

class _SearchViewBodyState extends State<SearchViewBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentScroll = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (currentScroll >= 0.7 * maxScroll) {
      context.read<SearchCubit>().fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchCubit, SearchState>(
      listener: (context, state) {
        // 1. لو الخطأ حصل في أول تحميل خالص
        if (state is SearchFailure) {
          showSnackBar(context, state.errmessage, Colors.red);
        }
        // 2. لو الخطأ حصل واحنا بنعمل سكرول وبنجيب الصفحة التانية
        if (state is SearchSuccess && state.paginationErrorMessage != null) {
          showSnackBar(context, state.paginationErrorMessage!, Colors.red);
        }
      },
      builder: (context, state) {
        final allSpecializations =
            state is SearchSuccess ? state.allSpecializations : [];
        final popularSpecialties =
            state is SearchSuccess
                ? state.popularSpecialties
                : kpopularSpecialties;
        final selectedSpecialty = state.selectedSpecialty;
        final searchQuery = state.searchQuery;

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchHeader(),
              SearchCard(
                searchQuery: searchQuery,
                onSearchChanged: (value) {
                  context.read<SearchCubit>().updateSearchQuery(value);
                },
                selectedSpecialty: selectedSpecialty,
                onSpecialtyChanged: (value) {
                  context.read<SearchCubit>().updateSelectedSpecialty(value);
                },
                allSpecializations: ['All Specialties', ...allSpecializations],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PopularSpecialtiesSection(
                  selectedSpecialty: selectedSpecialty,
                  popularSpecialties: popularSpecialties,
                  onSelected: (value) {
                    context.read<SearchCubit>().updateSelectedSpecialty(value);
                  },
                ),
              ),

              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Available Doctors",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),

              DoctorsListView(state: state),
            ],
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:graduation_project/core/constant.dart';
// import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
// import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card_loading_indicator.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_header.dart';

// class SearchViewBody extends StatefulWidget {
//   const SearchViewBody({super.key});

//   @override
//   State<SearchViewBody> createState() => _SearchViewBodyState();
// }

// class _SearchViewBodyState extends State<SearchViewBody> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     final currentScroll = _scrollController.position.pixels;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     if (currentScroll >= 0.7 * maxScroll) {
//       context.read<SearchCubit>().fetchNextPage();
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<SearchCubit, SearchState>(
//       listener: (context, state) {
//         // 1. لو الخطأ حصل في أول تحميل خالص
//         if (state is SearchFailure) {
//           showSnackBar(context, state.errmessage, Colors.red);
//         }
//         // 2. لو الخطأ حصل واحنا بنعمل سكرول وبنجيب الصفحة التانية
//         if (state is SearchSuccess && state.paginationErrorMessage != null) {
//           showSnackBar(context, state.paginationErrorMessage!, Colors.red);
//         }
//       },
//       builder: (context, state) {
//         final doctors = state is SearchSuccess ? state.doctors : [];
//         final allSpecializations =
//             state is SearchSuccess ? state.allSpecializations : [];
//         final popularSpecialties =
//             state is SearchSuccess
//                 ? state.popularSpecialties
//                 : kpopularSpecialties;
//         final selectedSpecialty = state.selectedSpecialty;
//         final searchQuery = state.searchQuery;

//         return SingleChildScrollView(
//           controller: _scrollController,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SearchHeader(),
//               SearchCard(
//                 searchQuery: searchQuery,
//                 onSearchChanged: (value) {
//                   context.read<SearchCubit>().updateSearchQuery(value);
//                 },
//                 selectedSpecialty: selectedSpecialty,
//                 onSpecialtyChanged: (value) {
//                   context.read<SearchCubit>().updateSelectedSpecialty(value);
//                 },
//                 allSpecializations: ['All Specialties', ...allSpecializations],
//               ),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: PopularSpecialtiesSection(
//                   selectedSpecialty: selectedSpecialty,
//                   popularSpecialties: popularSpecialties,
//                   onSelected: (value) {
//                     context.read<SearchCubit>().updateSelectedSpecialty(value);
//                   },
//                 ),
//               ),

//               const SizedBox(height: 15),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   "Available Doctors",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 15),

//               _buildDoctorsSection(state, doctors),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDoctorsSection(SearchState state, List<dynamic> doctors) {
//     if (state is SearchLoading && doctors.isEmpty) {
//       return ListView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: 4, // 4 كروت وهمية يملوا الشاشة
//         itemBuilder: (context, index) {
//           return const Padding(
//             padding: EdgeInsets.only(bottom: 10, left: 5, right: 5),
//             child: DoctorCardLoadingIndicator(),
//           );
//         },
//       );
//     }

//     if (state is SearchFailure) {
//       return Center(
//         child: Text(
//           state.errmessage,
//           textAlign: TextAlign.center,
//           style: const TextStyle(color: Colors.red),
//         ),
//       );
//     }

//     if (doctors.isEmpty && state is SearchSuccess) {
//       return Padding(
//         padding: EdgeInsets.all(40.h),
//         child: const Row(
//           children: [
//             Spacer(flex: 1),
//             Text(
//               "No doctors found",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
//             ),
//             Spacer(flex: 1),
//           ],
//         ),
//       );
//     }

//     // تم وضع الليستة وجزء التحميل في Column عشان يظهروا تحت بعض بشكل منظم
//     return Column(
//       children: [
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: doctors.length,
//           itemBuilder: (context, index) {
//             final doctor = doctors[index];
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
//               child: DoctorCard(
//                 doctorId: doctor.doctorId,
//                 fullName: doctor.fullName,
//                 imageUrl: doctor.profileImageUrl ?? '',
//                 specialty: doctor.specialization,
//                 rating: doctor.averageRating.toString(),
//                 totalReviews: doctor.totalReviews,
//                 yearsOfExperience: doctor.yearsOfExperience,
//                 consultationFee: doctor.consultationFee,
//                 isActive: doctor.isActive,
//               ),
//             );
//           },
//         ),

//         // Loader صغير بيظهر في آخر الصفحة لما نوصل لـ 70% وبيحمل الداتا الجديدة
//         if (state is SearchSuccess && state.isFetchingMore)
//           const Padding(
//             padding: EdgeInsets.only(bottom: 20, top: 10, left: 5, right: 5),
//             child: DoctorCardLoadingIndicator(),
//           ),
//       ],
//     );
//   }
// }
//------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/popular_specialties_section.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_card.dart';
// import 'package:graduation_project/features/search/presentation/views/widgets/search_header.dart';
// // import 'package:graduation_project/features/search/presentation/views/widgets/quick_filters.dart';

// class SearchViewBody extends StatefulWidget {
//   const SearchViewBody({super.key});

//   @override
//   State<SearchViewBody> createState() => _SearchViewBodyState();
// }

// class _SearchViewBodyState extends State<SearchViewBody> {
//   // الـ Initial State بتاعة الـ UI
//   String selectedSpecialty = "All Specialties";
//   String searchQuery = "";

//   // الدالة دي بتنده الـ Cubit عشان يعمل Search بالداتا الحالية
//   void _onSearchTriggered() {
//     context.read<SearchCubit>().triggerSearch(
//       query: searchQuery,
//       specialty: selectedSpecialty,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           const SearchHeader(),

//           SearchCard(
//             searchQuery: searchQuery,
//             onSearchChanged: (value) {
//               setState(() => searchQuery = value);
//               _onSearchTriggered();
//             },
//             selectedSpecialty: selectedSpecialty,
//             onSpecialtyChanged: (value) {
//               setState(() => selectedSpecialty = value);
//               _onSearchTriggered();
//             },
//             allSpecializations: [],
//           ),

//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: PopularSpecialtiesSection(
//               selectedSpecialty: selectedSpecialty,
//               onSelected: (value) {
//                 setState(() => selectedSpecialty = value);
//                 _onSearchTriggered();
//               },
//               popularSpecialties: [
//                 "Cardiology",
//                 "Dermatology",
//                 "Pediatrics",
//                 "Orthopedics",
//                 "Neurology",
//                 "Gynecology",
//                 "Dentistry",
//               ],
//             ),
//           ),

//           const SizedBox(height: 15),

//           // لو حابب تفعل الـ QuickFilters رجعها هنا
//           // const Padding(
//           //   padding: EdgeInsets.symmetric(horizontal: 16),
//           //   child: QuickFilters(),
//           // ),
//           // const SizedBox(height: 15),

//           // ---------------------------------------------------------
//           // هنا بنعرض الدكاترة بناءً على حالة الـ Cubit
//           // ---------------------------------------------------------
//           BlocBuilder<SearchCubit, SearchState>(
//             builder: (context, state) {
//               if (state is SearchLoading) {
//                 return const Padding(
//                   padding: EdgeInsets.only(top: 50),
//                   child: Center(child: CircularProgressIndicator()),
//                 );
//               } else if (state is SearchFailure) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 50),
//                   child: Center(
//                     child: Text(
//                       state.errmessage,
//                       style: const TextStyle(color: Colors.red, fontSize: 16),
//                     ),
//                   ),
//                 );
//               } else if (state is SearchSuccess) {
//                 if (state.doctors.isEmpty) {
//                   return const Padding(
//                     padding: EdgeInsets.only(top: 50),
//                     child: Center(
//                       child: Text(
//                         "No doctors found matching your search.",
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: state.doctors.length,
//                   itemBuilder: (context, index) {
//                     final doc = state.doctors[index];
//                     return Padding(
//                       padding: const EdgeInsets.only(
//                         bottom: 10,
//                         left: 16,
//                         right: 16,
//                       ),
//                       child: DoctorCard(
//                         // بنقرا من الـ DoctorEntity
//                         fullName: doc.fullName,
//                         imageUrl:
//                             doc.profileImageUrl ??
//                             'https://via.placeholder.com/150', // حط ديفولت هنا
//                         specialty: doc.specialization,
//                         rating: doc.averageRating.toString(),
//                         totalReviews: doc.totalReviews,
//                         yearsOfExperience: doc.yearsOfExperience,
//                         doctorId: doc.doctorId,
//                         consultationFee: doc.consultationFee,
//                         isActive: doc.isActive,
//                       ),
//                     );
//                   },
//                 );
//               }

//               // ده هيظهر لثواني بسيطة أول ما الصفحة تفتح قبل الـ Loading
//               return const SizedBox();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
