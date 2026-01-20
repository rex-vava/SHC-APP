// Update your appointment_model.dart

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String? patientPhone;
  final String patientHealthInsurance;
  final DateTime appointmentDate;
  final String appointmentTime;
  final DateTime date;     
  final String status;
 // 'pending', 'confirmed', 'cancelled', 'completed'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Add these new fields
  final int? patientAge;
  final String? patientGender;
  final String? patientMedicalHistory;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    this.patientPhone,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.patientHealthInsurance,
    required this.status,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    // Add to constructor
    this.patientAge,
    this.patientGender,
    this.patientMedicalHistory,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      doctorId: json['doctorId'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? 'Unknown Patient',
      patientEmail: json['patientEmail'] ?? '',
      patientPhone: json['patientPhone'],
      appointmentDate: DateTime.parse(json['appointmentDate'] ?? DateTime.now().toString()),
      appointmentTime: json['appointmentTime'] ?? '',
      patientHealthInsurance: json['patientHealthInsurance'] ?? '',
      status: json['status'] ?? 'pending',
      date: DateTime.parse(json['date']), // parse from ISO string
      
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      // Add parsing for new fields
      patientAge: json['patientAge'] != null ? int.tryParse(json['patientAge'].toString()) : null,
      patientGender: json['patientGender'],
      patientMedicalHistory: json['patientMedicalHistory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'appointmentDate': appointmentDate.toIso8601String(),
      'patientHealthInsurance': patientHealthInsurance,
      'appointmentTime': appointmentTime,
      'status': status,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Add new fields
      'patientAge': patientAge,
      'patientGender': patientGender,
      'patientMedicalHistory': patientMedicalHistory,
    };
  }
}