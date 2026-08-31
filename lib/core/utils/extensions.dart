import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

extension StringX on String {
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isValidEmail => RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  bool get isValidPhone => RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(this);
}

extension IntX on int {
  /// Format as XAF currency string, e.g. 23500 → "23 500 XAF"
  String get xaf {
    final fmt = NumberFormat('#,##0', 'fr_FR');
    return '${fmt.format(this)} XAF';
  }
}

extension DateTimeX on DateTime {
  String get formatted => DateFormat('dd MMM yyyy').format(this);
  String get formattedShort => DateFormat('dd/MM/yyyy').format(this);

  /// E.g. "27 Aug 2026 → 03 Sept 2026"
  String rangeUntil(DateTime end) =>
      '${DateFormat('dd MMM yyyy').format(this)} → ${DateFormat('dd MMM yyyy').format(end)}';

  int daysUntil(DateTime end) => end.difference(this).inDays;
}
