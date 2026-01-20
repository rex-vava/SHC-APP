import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment_model.dart';
import '../utils/api_config.dart';

class AppointmentService {
  static final String _baseUrl = ApiConfig.baseUrl;

  // ================= BOOK APPOINTMENT =================
  /// Books a new appointment with the backend Node.js API.
  /// Requires an authorization token, doctor ID, and patient ID.
  /// Optional notes can also be included.
  static Future<AppointmentModel> bookAppointment({
    required String token,
    required String doctorId,
    required String patientId,
    String? notes,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/appointments');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'doctorId': doctorId,
          'patientId': patientId,
          if (notes != null) 'notes': notes,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully booked appointment
        return AppointmentModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to book appointment');
      }
    } catch (e) {
      throw Exception('Error booking appointment: $e');
    }
  }

  // ================= PATIENT APPOINTMENTS =================
  static Future<List<AppointmentModel>> getAppointmentsByPatient(
      String token, String patientId) async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/patient/$patientId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List list = data['appointments'] ?? [];
        return list.map((e) => AppointmentModel.fromJson(e)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch patient appointments');
      }
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  // ================= DOCTOR APPOINTMENTS =================
  static Future<List<AppointmentModel>> getAppointmentsByDoctor({
    required String token,
    required String doctorId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/doctor/$doctorId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List list = data['appointments'] ?? [];
        return list.map((e) => AppointmentModel.fromJson(e)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch doctor appointments');
      }
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  // ================= CONFIRM APPOINTMENT =================
  static Future<AppointmentModel> confirmAppointment({
    required String token,
    required String appointmentId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/$appointmentId/confirm');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to confirm appointment');
      }
    } catch (e) {
      throw Exception('Error confirming appointment: $e');
    }
  }

  // ================= CANCEL APPOINTMENT =================
  static Future<AppointmentModel> cancelAppointment({
    required String token,
    required String appointmentId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/appointments/$appointmentId/cancel');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to cancel appointment');
      }
    } catch (e) {
      throw Exception('Error canceling appointment: $e');
    }
  }
}
