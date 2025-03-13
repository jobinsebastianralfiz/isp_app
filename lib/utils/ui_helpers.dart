import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/app_constants.dart';

class UIHelpers {
  // Show a snackbar
  static void showSnackBar(
      BuildContext context, {
        required String message,
        bool isError = false,
        Duration duration = const Duration(seconds: 4),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppConstants.errorColor : AppConstants.primaryColor,
        duration: duration,
      ),
    );
  }

  // Show toast message
  static void showToast({
    required String message,
    bool isError = false,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Duration duration = const Duration(seconds: 2),
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: isError ? AppConstants.errorColor : AppConstants.primaryColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Show a loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show a confirmation dialog
  static Future<bool> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Yes',
        String cancelText = 'No',
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText, style: TextStyle(color: AppConstants.primaryColor)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Custom text field
  static Widget customTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }

  // Primary button
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 12),
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: padding,
        minimumSize: isFullWidth ? const Size(double.infinity, 48) : null,
      ),
      child: isLoading
          ? const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}