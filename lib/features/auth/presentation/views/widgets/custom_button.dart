// file: core/widgets/custom_primary_button.dart

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // <-- السر هنا إنه nullable
  final Color backgroundColor;
  final Color disabledColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF6A72DA), // ده اللون البنفسجي
    this.disabledColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: disabledColor,
          foregroundColor: Colors.white, // لون التكست
          disabledForegroundColor: Colors.white.withOpacity(
            0.8,
          ), // لون التكست وهو مقفول
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0, // عشان يبقى flat زي ما كان
        ),
        onPressed: onPressed, // <-- هنا بنمرر الـ callback
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
