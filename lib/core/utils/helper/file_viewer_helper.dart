import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileViewerHelper {
  static Future<void> openSecureFile(
    BuildContext context,
    String url,
    String originalFileName,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
    );

    try {
      Dio dio;
      if (url.contains('ngrok-free.dev')) {
        dio = getIt<Dio>();
        print("🔗 Using Interceptor Dio (Internal Link)");
      } else {
        dio = Dio();
        print("☁️ Using Clean Dio (External Link)");
      }
      print("👉 Trying to download URL: $url");
      String cleanName = originalFileName.split('?').first;
      final tempDir = await getTemporaryDirectory();
      final savePath = "${tempDir.path}/$cleanName";

      print("📥 Downloading file to: $savePath");

      await dio.download(url, savePath);

      if (context.mounted) Navigator.pop(context);

      final result = await OpenFilex.open(savePath);

      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Could not open file: ${result.message}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error opening file: $e"),
            backgroundColor: Colors.red,
          ),
        );
        print("❌ Error downloading: $e");
      }
    }
  }
}
