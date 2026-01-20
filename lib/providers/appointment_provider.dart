import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../services/socket_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  final SocketService _socketService = SocketService();

  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPatientAppointments({
    required String token,
    required String patientId,
  }) async {
    _setLoading(true);
    try {
      _appointments = await AppointmentService.getAppointmentsByPatient(
        token,
        patientId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ================== FETCH DOCTOR APPOINTMENTS ==================
  Future<void> fetchDoctorAppointments({
    required String token,
    required String doctorId,
  }) async {
    _setLoading(true);
    try {
      _appointments = await AppointmentService.getAppointmentsByDoctor(
        token: token,
        doctorId: doctorId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ================== BOOK APPOINTMENT ==================
  Future<void> bookAppointment({
    required String token,
    required String doctorId,
    required String patientId,
    String? notes,
  }) async {
    try {
      final newAppointment = await AppointmentService.bookAppointment(
        token: token,
        doctorId: doctorId,
        patientId: patientId,
        notes: notes,
      );

      _appointments.insert(0, newAppointment);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to book appointment');
    }
  }

  // ================== CONFIRM APPOINTMENT ==================
  Future<void> confirmAppointment({
    required String token,
    required String appointmentId,
  }) async {
    try {
      final updated = await AppointmentService.confirmAppointment(
        token: token,
        appointmentId: appointmentId,
      );

      _updateLocalAppointment(updated);
    } catch (e) {
      throw Exception('Failed to confirm appointment');
    }
  }

  // ================== CANCEL APPOINTMENT ==================
  Future<void> cancelAppointment({
    required String token,
    required String appointmentId,
  }) async {
    try {
      final updated = await AppointmentService.cancelAppointment(
        token: token,
        appointmentId: appointmentId,
      );

      _updateLocalAppointment(updated);
    } catch (e) {
      throw Exception('Failed to cancel appointment');
    }
  }

  // ================== SOCKET LISTENER ==================
  void listenForUpdates() {
    _socketService.onAppointmentUpdated((data) {
      final updated = AppointmentModel.fromJson(data);
      _updateLocalAppointment(updated);
    });
  }

  // ================== HELPERS ==================
  void _updateLocalAppointment(AppointmentModel appointment) {
    final index =
        _appointments.indexWhere((a) => a.id == appointment.id);

    if (index != -1) {
      _appointments[index] = appointment;
    } else {
      _appointments.insert(0, appointment);
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clear() {
    _appointments.clear();
    _error = null;
    notifyListeners();
  }
}
