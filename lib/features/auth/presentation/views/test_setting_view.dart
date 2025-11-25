// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
// import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   late Box settingsBox;
//   bool isBiometricEnabled = false;
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

//   @override
//   void initState() {
//     super.initState();

//     settingsBox = Hive.box('settings');
//     isBiometricEnabled = settingsBox.get(
//       'biometric_enabled',
//       defaultValue: false,
//     );
//   }

//   Future<void> _toggleBiometric(bool value) async {
//     final localAuth = LocalAuthentication();
//     bool didAuthenticate = await localAuth.authenticate(
//       localizedReason: 'تأكيد الهوية بالبصمة',
//     );

//     if (didAuthenticate) {
//       try {
//         settingsBox.put('biometric_enabled', value);
//         setState(() => isBiometricEnabled = value);
//         if (value)
//           ShowSnackBar(context, 'تم تفعيل البصمة بنجاح ✅', Colors.green);
//         else
//           ShowSnackBar(context, 'تم تعطيل البصمة بنجاح ✅', Colors.green);
//       } catch (e) {
//         ShowSnackBar(context, 'حدث خطأ أثناء التفعيل: $e', Colors.red);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
// <<<<<<< HEAD
//       appBar: AppBar(
//         title: Text('Settings', style: TextStyle(fontSize: 20.sp)),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           children: [
//             SwitchListTile(
//               title: Text(
//                 'تسجيل الدخول بالبصمة',
//                 style: TextStyle(fontSize: 16.sp),
//               ),
//               value: isBiometricEnabled,
//               onChanged: _toggleBiometric,
//             ),
//             SizedBox(height: 20.h), // **مسافة ديناميكية بين العناصر**
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   padding: EdgeInsets.symmetric(
//                     vertical: 14.h,
//                   ), // **button height responsive**
//                 ),
//                 onPressed: () async {
//                   await SecureStorageHelper.clearTokens();
//                   await Hive.box('settings').put('biometric_enabled', false);

//                   if (!mounted) return;
//                   context.go(AppRouter.kLogin);
//                 },
//                 child: Text(
//                   "Logout",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16.sp,
//                   ), // **responsive font**
//                 ),
//               ),
//             ),
//           ],
//         ),
// =======
//       appBar: AppBar(title: const Text('Settings')),
//       body: Column(
//         children: [
//           SwitchListTile(
//             title: const Text('تسجيل الدخول بالبصمة'),
//             value: isBiometricEnabled,
//             onChanged: _toggleBiometric,
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () async {
//               final GoogleSignIn googleSignIn = getIt<GoogleSignIn>();
//               await SecureStorageHelper.clearTokens();
//               await Hive.box('settings').put('biometric_enabled', false);
//               await googleSignIn.signOut();
//               if (!mounted) return;
//               context.go(AppRouter.kLogin);
//             },
//             child: const Text("Logout", style: TextStyle(color: Colors.white)),
//           ),
//         ],
// >>>>>>> origin/merge-v2
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  bool isBiometricEnabled = false;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    settingsBox = Hive.box('settings');
    isBiometricEnabled = settingsBox.get(
      'biometric_enabled',
      defaultValue: false,
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    final localAuth = LocalAuthentication();
    bool didAuthenticate = await localAuth.authenticate(
      localizedReason: 'تأكيد الهوية بالبصمة',
    );

    if (didAuthenticate) {
      try {
        settingsBox.put('biometric_enabled', value);
        setState(() => isBiometricEnabled = value);
        if (value)
          ShowSnackBar(context, 'تم تفعيل البصمة بنجاح ✅', Colors.green);
        else
          ShowSnackBar(context, 'تم تعطيل البصمة بنجاح ✅', Colors.green);
      } catch (e) {
        ShowSnackBar(context, 'حدث خطأ أثناء التفعيل: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('تسجيل الدخول بالبصمة'),
            value: isBiometricEnabled,
            onChanged: _toggleBiometric,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final GoogleSignIn googleSignIn = getIt<GoogleSignIn>();
              await SecureStorageHelper.clearTokens();
              await Hive.box('settings').put('biometric_enabled', false);
              await googleSignIn.signOut();
              if (!mounted) return;
              context.go(AppRouter.kLogin);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
