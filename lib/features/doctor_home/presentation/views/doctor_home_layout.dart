import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/auth/presentation/views/chat_view.dart';
import 'package:graduation_project/features/auth/presentation/views/schedule_view.dart';
import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/doctor_home_view.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_completion_dialog.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/doctor_profile_view.dart';

class DoctorHomeLayout extends StatefulWidget {
  const DoctorHomeLayout({super.key});

  @override
  State<DoctorHomeLayout> createState() => _DoctorHomeLayoutState();
}

class _DoctorHomeLayoutState extends State<DoctorHomeLayout> {
  int _currentIndex = 0;

  // ✅ Flag لتحديد إذا كان البروفايل مكتمل أو لا
  // في المستقبل هنجيبها من الـ API أو الـ Local Storage
  bool _isProfileComplete = false; // مش final
  bool _isLoadingStatus = true;

  // ✅ نتأكد إن الـ Dialog يظهر مرة واحدة بس
  bool _hasShownDialog = false;

  final List<Widget> _screens = const [
    DoctorHomeView(), // شاشة هوم الدكتور اللي هتبدأ ترسمها
    ScheduleView(),
    ChatView(), // مشتركة (الباك بيفرق بالتوكن)
    DoctorProfileView(),
    SettingsScreen(), // مشتركة
  ];

  static const Color activeBlue = Color(0xFF1B4E8C);
  static const Color activeGreen = Color(0xFF4CAF50);
  static const Color inactiveGray = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadProfileStatus();
  }

  Future<void> _loadProfileStatus() async {
    final result =
        await getIt<DoctorProfileCubit>().repository.checkProfileStatus();

    result.fold(
      (_) {
        if (mounted) setState(() => _isLoadingStatus = false);
      },
      (data) {
        if (mounted) {
          final isActive = data['isActive'] == true;
          setState(() {
            _isProfileComplete = isActive;
            _isLoadingStatus = false;
          });

          // لو مش مكتمل، اظهر الـ dialog
          if (!isActive && !_hasShownDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showProfileCompletionDialog();
              _hasShownDialog = true;
            });
          }
        }
      },
    );
  }

  // ✅ دالة إظهار الـ Dialog
  void _showProfileCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // المستخدم مش يقدر يقفل الـ Dialog بالضغط برا
      builder: (context) => const ProfileCompletionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingStatus) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      // ✅ لو البروفايل مش مكتمل، نعمل Blur على كل الشاشة
      body: Stack(
        children: [
          // الشاشة الأساسية
          _screens[_currentIndex],

          // ✅ Blurred Overlay (يظهر بس لو البروفايل مش مكتمل)
          if (!_isProfileComplete)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
            ),
        ],
      ),

      // ✅ Bottom Navigation (يتعطل لو البروفايل مش مكتمل)
      bottomNavigationBar:
          _isProfileComplete
              ? _buildBottomNavigationBar()
              : _buildDisabledBottomNavigationBar(),
    );
  }

  // ✅ Bottom Navigation عادي (مفعل)
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _currentIndex,
        selectedItemColor: activeBlue,
        unselectedItemColor: inactiveGray,
        showUnselectedLabels: true,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          _buildNavItem(Icons.home_filled, 'Home', 0),
          _buildNavItem(Icons.schedule, 'Schedule', 1),
          _buildNavItem(Icons.chat, 'Chats', 2),
          _buildNavItem(Icons.account_circle_outlined, 'Profile', 3),
          _buildNavItem(Icons.settings, 'Settings', 4),
        ],
      ),
    );
  }

  // ✅ Bottom Navigation معطل (لما البروفايل مش مكتمل)
  Widget _buildDisabledBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: 0,
        selectedItemColor: inactiveGray,
        unselectedItemColor: inactiveGray.withValues(alpha: 0.5),
        showUnselectedLabels: true,
        onTap: null, // ✅ معطل
        items: [
          _buildDisabledNavItem(Icons.home_filled, 'Home'),
          _buildDisabledNavItem(Icons.schedule, 'Schedule'),
          _buildDisabledNavItem(Icons.chat, 'Chats'),
          _buildDisabledNavItem(Icons.account_circle_outlined, 'Profile'),
          _buildDisabledNavItem(Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final bool isActive = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          Icon(icon, color: isActive ? activeBlue : inactiveGray),
          const SizedBox(height: 3),
          if (isActive)
            Container(
              width: 25,
              height: 3,
              decoration: BoxDecoration(
                color: activeGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildDisabledNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          Icon(icon, color: inactiveGray.withValues(alpha: 0.5)),
          const SizedBox(height: 3),
        ],
      ),
      label: label,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/auth/presentation/views/chat_view.dart';
// import 'package:graduation_project/features/auth/presentation/views/schedule_view.dart';
// import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
// import 'package:graduation_project/features/doctor_home/presentation/views/doctor_home_view.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/doctor_profile_view.dart';
// // استورد صفحة بروفايل الدكتور هنا

// class DoctorHomeLayout extends StatefulWidget {
//   const DoctorHomeLayout({super.key});

//   @override
//   State<DoctorHomeLayout> createState() => _DoctorHomeLayoutState();
// }

// class _DoctorHomeLayoutState extends State<DoctorHomeLayout> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = const [
//     DoctorHomeView(), // شاشة هوم الدكتور اللي هتبدأ ترسمها
//     ScheduleView(),
//     ChatView(), // مشتركة (الباك بيفرق بالتوكن)
//     DoctorProfileView(),
//     SettingsScreen(), // مشتركة
//   ];

//   static const Color activeBlue = Color(0xFF1B4E8C);
//   static const Color activeGreen = Color(0xFF4CAF50);
//   static const Color inactiveGray = Colors.grey;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha:0.05),
//               blurRadius: 5,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           currentIndex: _currentIndex,
//           selectedItemColor: activeBlue,
//           unselectedItemColor: inactiveGray,
//           showUnselectedLabels: true,
//           onTap: (index) => setState(() => _currentIndex = index),
//           items: [
//             _buildNavItem(Icons.home_filled, 'Home', 0),
//             _buildNavItem(Icons.schedule, 'Schedule', 1),
//             _buildNavItem(Icons.chat, 'Chats', 2),
//             _buildNavItem(Icons.account_circle_outlined, 'Profile', 3),
//             _buildNavItem(Icons.settings, 'Settings', 4),
//           ],
//         ),
//       ),
//     );
//   }

//   BottomNavigationBarItem _buildNavItem(
//     IconData icon,
//     String label,
//     int index,
//   ) {
//     final bool isActive = _currentIndex == index;
//     return BottomNavigationBarItem(
//       icon: Column(
//         children: [
//           Icon(icon, color: isActive ? activeBlue : inactiveGray),
//           const SizedBox(height: 3),
//           if (isActive)
//             Container(
//               width: 25,
//               height: 3,
//               decoration: BoxDecoration(
//                 color: activeGreen,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//         ],
//       ),
//       label: label,
//     );
//   }
// }
