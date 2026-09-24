abstract final class Validators {
  static String? required(String? value, {String label = 'This field'}) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  static String? email(String? value) {
    final requiredError = required(value, label: 'Email');
    if (requiredError != null) return requiredError;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address.';
  }

  static String? password(String? value) {
    final requiredError = required(value, label: 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < 8) return 'Password must be at least 8 characters.';
    if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must include a letter and a number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    return value == password ? null : 'Passwords do not match.';
  }
}
