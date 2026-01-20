// lib/services/doctor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';

class DoctorService {
  // Local backend URL (Android emulator uses 10.0.2.2, web uses 127.0.0.1)
  static const String baseUrl = 'http://127.0.0.1:5000/api/doctors';
  // If testing on a real device, replace 127.0.0.1 with your PC IP

  /// CREATE doctor profile
  static Future<Doctor?> createDoctorProfile(Doctor doctor) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(doctor.toJson()),
      );

      if (response.statusCode == 201) {
        return Doctor.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to create doctor: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Create doctor error: $e');
      return null;
    }
  }

  /// GET doctor profile by userId
  static Future<Doctor?> getDoctorProfileByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/$userId'),
      );

      if (response.statusCode == 200) {
        return Doctor.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        print('Doctor not found for userId: $userId');
        return null;
      } else {
        print('Failed to fetch doctor: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Get doctor error: $e');
      return null;
    }
  }

  /// GET all doctors (optional, backend currently does not have this endpoint)
  static Future<List<Doctor>> getDoctors() async {
    // If you implement GET /api/doctors in backend, you can use this
    print('getDoctors() endpoint not implemented yet on backend');
    return [];
  }
}
