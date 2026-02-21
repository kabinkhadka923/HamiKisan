class Validators {
  static bool isValidPhoneNumber(String? value) {
    if (value == null) return false;
    final phoneRegex = RegExp(r'^9[678][0-9]{8}$');
    return phoneRegex.hasMatch(value);
  }

  static bool isValidEmail(String? value) {
    if (value == null) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  static bool isValidName(String? value) {
    if (value == null) return false;
    return value.trim().length >= 2;
  }
}
