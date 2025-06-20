class Validators {
  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Basic email validation pattern
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailPattern.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  // Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }

    return null;
  }

  // Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    final namePattern = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!namePattern.hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens and apostrophes';
    }

    // Check if name has at least first and last name
    final nameParts = value.trim().split(RegExp(r'\s+'));
    if (nameParts.length < 2) {
      return 'Please enter your full name (first and last name)';
    }

    return null;
  }

  // Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Check for Indian mobile number patterns
    if (digitsOnly.length == 10) {
      // 10-digit mobile number
      final mobilePattern = RegExp(r'^[6-9]\d{9}$');
      if (!mobilePattern.hasMatch(digitsOnly)) {
        return 'Please enter a valid Indian mobile number starting with 6-9';
      }
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('0')) {
      // 11-digit number starting with 0 (landline with STD code)
      final landlinePattern = RegExp(r'^0[1-9]\d{9}$');
      if (!landlinePattern.hasMatch(digitsOnly)) {
        return 'Please enter a valid landline number with STD code';
      }
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      // 12-digit number starting with country code 91
      final countryCodePattern = RegExp(r'^91[6-9]\d{9}$');
      if (!countryCodePattern.hasMatch(digitsOnly)) {
        return 'Please enter a valid Indian mobile number with country code';
      }
    } else {
      return 'Please enter a valid 10-digit mobile or 11-digit landline number';
    }

    return null;
  }
}