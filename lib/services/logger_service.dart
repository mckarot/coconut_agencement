import 'package:flutter/foundation.dart';

/// Service de logging pour l'application
/// Remplace les appels print() par un système de logging approprié
class LoggerService {
  static const String _tag = 'CoconutAgencement';

  /// Log de type debug - uniquement en mode debug
  static void debug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$_tag] DEBUG: $message');
    }
  }

  /// Log de type info - informations générales
  static void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$_tag] INFO: $message');
    }
  }

  /// Log de type warning - avertissements
  static void warning(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$_tag] WARNING: $message');
    }
  }

  /// Log de type error - erreurs
  static void error(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$_tag] ERROR: $message');
    }
  }

  /// Log de type exception - erreurs avec stack trace
  static void exception(String message, dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$_tag] EXCEPTION: $message\nError: $error\nStack Trace: $stackTrace');
    }
  }
}