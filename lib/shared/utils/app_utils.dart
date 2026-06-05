import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Extension methods for String class
extension StringExtensions on String {
  /// Capitalizes the first character
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Checks if string is a valid email
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Checks if string is a valid phone number
  bool isValidPhone() {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[\s\-+()]'), ''));
  }

  /// Checks if string is a strong password
  bool isStrongPassword() {
    return length >= 8 &&
        contains(RegExp(r'[a-z]')) &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[0-9]'));
  }

  /// Truncates string to specified length with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Obfuscates email (shows first char and last domain)
  String obfuscateEmail() {
    if (!contains('@')) return this;
    final parts = split('@');
    return '${parts[0][0]}***@${parts[1]}';
  }
}

/// Extension methods for DateTime class
extension DateTimeExtensions on DateTime {
  /// Returns formatted date string
  String toFormattedDate({String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(this);
  }

  /// Returns time ago string (e.g., "2 hours ago")
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  /// Returns whether date is today
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns whether date is yesterday
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns whether date is in the past
  bool isPast() {
    return isBefore(DateTime.now());
  }

  /// Returns whether date is in the future
  bool isFuture() {
    return isAfter(DateTime.now());
  }
}

/// Extension methods for num class (int and double)
extension NumExtensions on num {
  /// Formats number as currency
  String toCurrency({String symbol = 'Rs', int decimals = 2}) {
    return '$symbol ${toStringAsFixed(decimals)}';
  }

  /// Formats number as percentage
  String toPercentage({int decimals = 1}) {
    return '${toStringAsFixed(decimals)}%';
  }

  /// Converts bytes to readable format
  String bytesToReadable() {
    if (this < 1024) return '${toStringAsFixed(2)} B';
    if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(2)} KB';
    }
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Extension methods for List class
extension ListExtensions<T> on List<T> {
  /// Removes duplicate items from list
  List<T> removeDuplicates() {
    return toSet().toList();
  }

  /// Checks if list is empty or null
  bool get isNullOrEmpty => isEmpty;

  /// Safely gets element at index or returns default
  T? getOrNull(int index, {T? defaultValue}) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return defaultValue;
  }

  /// Chunks list into smaller lists
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

/// Extension methods for BuildContext
extension BuildContextExtensions on BuildContext {
  /// Gets screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Gets screen width
  double get screenWidth => screenSize.width;

  /// Gets screen height
  double get screenHeight => screenSize.height;

  /// Gets screen padding (notch, etc.)
  EdgeInsets get screenPadding => MediaQuery.of(this).padding;

  /// Gets screen view insets (keyboard, etc.)
  EdgeInsets get screenViewInsets => MediaQuery.of(this).viewInsets;

  /// Checks if device is in landscape mode
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Checks if device is in portrait mode
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  /// Checks if device is phone-sized
  bool get isPhone => screenWidth < 600;

  /// Checks if device is tablet-sized
  bool get isTablet => screenWidth >= 600;

  /// Gets device density
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Shows snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration, action: action),
    );
  }

  /// Shows error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {
          ScaffoldMessenger.of(this).hideCurrentSnackBar();
        },
      ),
    );
  }

  /// Shows loading dialog
  void showLoadingDialog({String message = 'Loading...'}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  /// Dismisses current dialog
  void dismissDialog() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }
}

/// Utility functions for common operations
class AppUtils {
  /// Validates form field
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!(value?.isValidEmail() ?? false)) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Validates password field
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if ((value?.length ?? 0) < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value!.isStrongPassword()) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }
    return null;
  }

  /// Validates name field
  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Name is required';
    }
    if ((value?.length ?? 0) < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  /// Validates phone field
  static String? validatePhone(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Phone is required';
    }
    if (!value!.isValidPhone()) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates URL
  static String? validateUrl(String? value) {
    if (value?.isEmpty ?? true) {
      return 'URL is required';
    }
    try {
      Uri.parse(value!);
      return null;
    } catch (_) {
      return 'Enter a valid URL';
    }
  }

  /// Generates random string
  static String generateRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
    final random = <String>[];
    for (int i = 0; i < length; i++) {
      random.add(chars[DateTime.now().millisecond % chars.length]);
    }
    return random.join();
  }

  /// Debounces function
  static Future<T> debounce<T>(
    Duration duration,
    Future<T> Function() operation,
  ) async {
    await Future.delayed(duration);
    return operation();
  }
}

/// Extension for GetX navigation
extension GetXNavigationExtensions on GetxController {
  /// Navigate to named route with parameters
  Future<T?>? navigateTo<T>(String routeName, {dynamic arguments}) {
    return Get.toNamed(routeName, arguments: arguments);
  }

  /// Replace current route
  Future<T?>? replaceRoute<T>(String routeName, {dynamic arguments}) {
    return Get.offNamed(routeName, arguments: arguments);
  }

  /// Replace all routes
  Future<T?>? replaceAllRoutes<T>(String routeName, {dynamic arguments}) {
    return Get.offAllNamed(routeName, arguments: arguments);
  }

  /// Go back
  void goBack<T>({T? result}) {
    Get.back(result: result);
  }
}
