abstract final class Validators {
  static final RegExp _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  static String? required(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final String? requiredMessage = required(value, fieldName: 'Email');
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? fullName(String? value) {
    final String? requiredMessage = required(value, fieldName: 'Full name');
    if (requiredMessage != null) {
      return requiredMessage;
    }
    if (value!.trim().length < 2) {
      return 'Full name must contain at least 2 characters.';
    }
    return null;
  }

  static String? mobile(String? value) {
    final String? requiredMessage = required(value, fieldName: 'Mobile number');
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final String normalized = value!.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(?:\+91)?[6-9]\d{9}$').hasMatch(normalized)) {
      return 'Enter a valid 10-digit mobile number.';
    }
    return null;
  }

  static String? interestMessage(String? value) {
    final String? requiredMessage = required(value, fieldName: 'Message');
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final int length = value!.trim().length;
    if (length < 10) {
      return 'Message must contain at least 10 characters.';
    }
    if (length > 500) {
      return 'Message cannot exceed 500 characters.';
    }
    return null;
  }
}
