import 'package:air_query/core/constants/business_constants.dart';

class AuthValidators {
  /// To check if the email is non-empty
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    return null;
  }

  /// To check if the password satisfies min and max char constraints
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    if (value.trim().length < BusinessConstants.minPassChars) {
      return "Password must have at least ${BusinessConstants.minPassChars} characters";
    }
    if (value.trim().length > BusinessConstants.maxPassChars) {
      return "Password cannot exceed ${BusinessConstants.maxPassChars} characters";
    }
    return null;
  }
}
