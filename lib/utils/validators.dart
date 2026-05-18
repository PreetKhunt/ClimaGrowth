class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!re.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final re = RegExp(r'^\+?[0-9]{10,13}$');
    if (!re.hasMatch(value.trim())) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? farmSize(String? value) {
    if (value == null || value.trim().isEmpty) return 'Farm size is required';
    final n = double.tryParse(value);
    if (n == null || n <= 0) return 'Enter a valid farm size in acres';
    return null;
  }
}
