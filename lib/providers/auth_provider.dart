import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/patient_model.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import '../services/doctor_service.dart';
import '../models/doctor_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  PatientModel? _currentPatient;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAuthenticated => _user != null && _token != null;
  bool get isDoctor => _user?.userType == 'doctor';
  bool get isPatient => _user?.userType == 'patient';

  AuthProvider() {
    loadUserData();
  }

  // --------------------------------------------------
  // LOAD SAVED SESSION
  // --------------------------------------------------
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userData = prefs.getString('current_user');

    if (token != null && userData != null) {
      _token = token;
      _user = User.fromJson(json.decode(userData));
      notifyListeners();
    }
  }

  Future<void> _saveUserData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('current_user', json.encode(user.toJson()));
  }

  // --------------------------------------------------
  // LOGIN
  // --------------------------------------------------
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        _token = result['token'];
        _user = result['user'];
        await _saveUserData(_token!, _user!);
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': _error};
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  // --------------------------------------------------
  // REGISTER (USER + DOCTOR PROFILE IF NEEDED)
  // --------------------------------------------------
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String userType,

    String? nationalId,
    String? dateOfBirth,
    String? gender,

    // Doctor-only fields
    String? licenseNumber,
    String? specialization,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        userType: userType,
        nationalId: nationalId,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      if (result['success'] != true) {
        throw result['message'];
      }

      _token = result['token'];
      _user = result['user'];
      await _saveUserData(_token!, _user!);

      // ✅ CONNECT DOCTOR REGISTRATION → DOCTOR PROFILE
      if (userType == 'doctor') {
        final doctorProfile = Doctor(
          id: _user!.id,
          name: '$firstName $lastName',
          email: email,
          specialization: specialization ?? 'General Practitioner',
          yearsOfExperience: 0,
          hospitalAffiliation: 'Not specified',
          rating: 0.0,
          languagesSpoken: ['English'],
          consultationFee: 0.0,
          isAvailable: true,
          education: '',
          awards: '',
        );

        await DoctorService.createDoctorProfile(doctorProfile);
      }

      _isLoading = false;
      notifyListeners();
      return {'success': true};
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    _token = null;
    _currentPatient = null;
    notifyListeners();
  }
  String? get userType => _user?.userType;
String? get userName => '${_user?.firstName ?? ''} ${_user?.lastName ?? ''}';
PatientModel? get currentPatient => _currentPatient;
void setCurrentPatient(PatientModel patient) {
  _currentPatient = patient;
  notifyListeners();
}


  final socketService = SocketService();
}
