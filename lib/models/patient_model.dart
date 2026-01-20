class PatientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String age;
  final String gender;
  final String medicalHistory;

  // 🔹 NEW
  final String healthInsurance;
  final String? mutuelleNumber;
  final String token;

  PatientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    required this.healthInsurance,
    this.mutuelleNumber,
    required this.token,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      age: json['age'],
      gender: json['gender'],
      medicalHistory: json['medicalHistory'] ?? '',
      healthInsurance: json['healthInsurance'] ?? '',
      mutuelleNumber: json['mutuelleNumber'],
      token: json['token'] ?? '',
    );
  }
}
