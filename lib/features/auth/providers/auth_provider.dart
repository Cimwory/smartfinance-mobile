import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Providers
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(dioClientProvider).dio);
});

// State
class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;

  AuthNotifier(this._dio) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      try {
        final response = await _dio.get(ApiConstants.user);
        state = state.copyWith(
          isAuthenticated: true,
          user: response.data,
        );
      } catch (e) {
        // Token invalid or expired
        await logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final user = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
      return true;
    } on DioException catch (e) {
      String errorMessage = 'Failed to login';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final token = response.data['access_token'];
      final user = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
      return true;
    } on DioException catch (e) {
      String errorMessage = 'Failed to register';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> sendOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.forgotPassword, data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to send OTP');
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'An error occurred';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.verifyOtp, data: {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Invalid OTP');
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'An error occurred';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String email, String otp, String password, String passwordConfirmation) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.resetPassword, data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to reset password');
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'An error occurred during password reset';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Profile Update
  Future<bool> updateProfile(String? username, File? avatarFile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      FormData formData = FormData();
      
      if (username != null && username.isNotEmpty) {
        formData.fields.add(MapEntry('username', username));
      }
      
      if (avatarFile != null) {
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(
              avatarFile.path,
              filename: avatarFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(ApiConstants.profileUpdate, data: formData);

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          user: response.data['user'],
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Gagal memperbarui profil');
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Terjadi kesalahan saat memperbarui profil';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Request OTP for Email Change
  Future<bool> requestEmailChangeOtp(String newEmail) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.profileRequestEmailOtp, data: {
        'new_email': newEmail,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Gagal mengirim OTP ke email baru');
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Terjadi kesalahan saat meminta OTP email baru';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Verify OTP for Email Change
  Future<bool> verifyEmailChangeOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(ApiConstants.profileVerifyEmailOtp, data: {
        'otp': otp,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          user: response.data['user'],
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Gagal memverifikasi OTP');
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Terjadi kesalahan saat memverifikasi OTP';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '770067747064-urnobnctuh9p5d150oifc9j4s7hvgs6f.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return false; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        state = state.copyWith(isLoading: false, error: 'Google Access Token is null');
        return false;
      }

      final response = await _dio.post('/auth/google', data: {
        'access_token': accessToken,
      });

      final token = response.data['access_token'];
      final user = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
      return true;
    } on DioException catch (e) {
      String errorMessage = 'Failed to authenticate with Google: ${e.message ?? e.type.toString()}';
      if (e.response?.data != null && e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignore errors on logout
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      state = AuthState(); // Reset state
    }
  }
}
