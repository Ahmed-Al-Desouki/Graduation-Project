import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
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
        log("🔗 Using Interceptor Dio (Internal Link)");
      } else {
        dio = Dio();
        log("☁️ Using Clean Dio (External Link)");
      }
      log("👉 Trying to download URL: $url");
      String cleanName = originalFileName.split('?').first;
      final tempDir = await getTemporaryDirectory();
      final savePath = "${tempDir.path}/$cleanName";

      log("📥 Downloading file to: $savePath");

      await dio.download(url, savePath);

      if (context.mounted) Navigator.pop(context);

      final result = await OpenFilex.open(savePath);

      if (result.type != ResultType.done) {
        if (context.mounted) {
          showSnackBar(
            context,
            "Could not open file: ${result.message}",
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);

        showSnackBar(context, "Error opening file: $e", Colors.red);
        log("❌ Error downloading: $e");
      }
    }
  }
}
