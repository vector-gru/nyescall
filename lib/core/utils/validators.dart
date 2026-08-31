/// Reusable field validators compatible with Flutter Form / TextFormField.
library;

class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required.';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Enter a valid phone number.';
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters.';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters.';
    }
    return null;
  }
}
