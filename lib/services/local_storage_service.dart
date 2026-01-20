import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Save appointments
  Future<void> saveAppointments(List<Map<String, dynamic>> appointments) async {
    final prefs = await _prefs;
    await prefs.setString('appointments', json.encode(appointments));
  }

  // Get appointments
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final prefs = await _prefs;
    final data = prefs.getString('appointments');
    if (data != null) {
      return List<Map<String, dynamic>>.from(json.decode(data));
    }
    return [];
  }

  // Save medical history
  Future<void> saveMedicalHistory(List<Map<String, dynamic>> history) async {
    final prefs = await _prefs;
    await prefs.setString('medical_history', json.encode(history));
  }

  // Get medical history
  Future<List<Map<String, dynamic>>> getMedicalHistory() async {
    final prefs = await _prefs;
    final data = prefs.getString('medical_history');
    if (data != null) {
      return List<Map<String, dynamic>>.from(json.decode(data));
    }
    return [];
  }

  // Clear all data (for logout)
  Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}