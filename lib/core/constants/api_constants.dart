class ApiConstants {
  // If running Laravel on localhost with Android Emulator, use 10.0.2.2.
  // For physical devices or other emulators, replace with your local IP (e.g. 192.168.x.x)
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  static const String login = '/login';
  static const String register = '/register';
  static const String user = '/user';
  static const String logout = '/logout';
  
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';

  // Profile
  static const String profileUpdate = '/profile/update';
  static const String profileRequestEmailOtp = '/profile/change-email/request-otp';
  static const String profileVerifyEmailOtp = '/profile/change-email/verify-otp';
}
