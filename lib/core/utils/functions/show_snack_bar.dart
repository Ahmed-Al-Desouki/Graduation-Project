import 'package:flutter/material.dart';

void ShowSnackBar(BuildContext context, String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: backgroundColor),
  );
}
