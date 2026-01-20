import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthService {
  /// =========================
  /// REGISTER USER (LOCAL)
  /// =========================
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String userType,
    String? nationalId,
    String? dateOfBirth,
    String? gender,
    String? licenseNumber,
    String? specialization,
    String? healthInsurance,
    String? mutuelleNumber,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('users') ?? [];

      // ✅ Check if email already exists
      final emailExists = existingUsers.any((userJson) {
        try {
          final map = json.decode(userJson);
          return map['email'] == email;
        } catch (_) {
          return false;
        }
      });

      if (emailExists) {
        return {
          'success': false,
          'message': 'User with this email already exists',
        };
      }

      // ✅ Create user
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        userType: userType,
        nationalId: nationalId,
        healthInsurance: healthInsurance,
        mutuelleNumber: mutuelleNumber,
        profilePicture: '',
        dateOfBirth:
            dateOfBirth != null ? DateTime.parse(dateOfBirth) : null,
        gender: gender,
        address: null,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // ✅ Save user locally
      existingUsers.add(json.encode(user.toJson()));
      await prefs.setStringList('users', existingUsers);

      // ✅ Save current session
      final token = 'local_token_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('current_user', json.encode(user.toJson()));
      await prefs.setString('token', token);

      return {
        'success': true,
        'message': 'Registration successful!',
        'token': token,
        'user': user,
      };
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'Registration failed',
      };
    }
  }

  /// =========================
  /// LOGIN USER (LOCAL)
  /// =========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('users') ?? [];

      for (final userJson in existingUsers) {
        final userMap = json.decode(userJson);
        if (userMap['email'] == email) {
          final user = User.fromJson(userMap);

          final token =
              'local_login_token_${DateTime.now().millisecondsSinceEpoch}';

          await prefs.setString('current_user', userJson);
          await prefs.setString('token', token);

          return {
            'success': true,
            'message': 'Login successful!',
            'token': token,
            'user': user,
          };
        }
      }

      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    } catch (e) {
      // TODO: Replace with proper logging
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Login failed',
      };
    }
  }

  /// =========================
  /// FORGOT PASSWORD (MOCK)
  /// =========================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Password reset instructions sent to $email (Simulated)',
    };
  }

  /// =========================
  /// GET CURRENT USER
  /// =========================
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('current_user');

      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  /// =========================
  /// CLEAR ALL USERS (TESTING)
  /// =========================
  static Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('users');
    await prefs.remove('current_user');
    await prefs.remove('token');
  }
}
