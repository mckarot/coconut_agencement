import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class NotificationService {
  static void showSuccess(BuildContext context, String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      icon: const Icon(
        Icons.check,
        color: Colors.white,
      ),
    ).show(context);
  }

  static void showError(BuildContext context, String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      icon: const Icon(
        Icons.error,
        color: Colors.white,
      ),
    ).show(context);
  }

  static void showInfo(BuildContext context, String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.blue,
      icon: const Icon(
        Icons.info,
        color: Colors.white,
      ),
    ).show(context);
  }
}
