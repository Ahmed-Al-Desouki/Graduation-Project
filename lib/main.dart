import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'Wellora',
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
