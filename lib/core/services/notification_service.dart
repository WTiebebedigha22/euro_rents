import 'package:flutter/material.dart';

/// Handles showing SnackBars and other notifications
class NotificationService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show a basic SnackBar
  static void showSnackBar(String message,
      {Color backgroundColor = Colors.black}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
    messengerKey.currentState?.showSnackBar(snackBar);
  }

  /// Show an error SnackBar
  static void showError(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }

  /// Show a success SnackBar
  static void showSuccess(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}
