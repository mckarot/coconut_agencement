import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'navigator_service.dart';

class NotificationService {
  static void showSuccess(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      Flushbar(
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ).show(context);
    });
  }

  static void showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      Flushbar(
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
      ).show(context);
    });
  }

  static void showInfo(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      Flushbar(
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.blue,
        icon: const Icon(
          Icons.info,
          color: Colors.white,
        ),
      ).show(context);
    });
  }
}
