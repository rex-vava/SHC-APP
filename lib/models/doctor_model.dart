// lib/models/doctor_model.dart

class Doctor {
  final String id; // MongoDB _id
  final String name;
  final String email;
  final String specialization;
  final int yearsOfExperience;
  final String hospitalAffiliation;
  final double rating;
  final List<String> languagesSpoken;
  final double consultationFee;
  final bool isAvailable;
  final String education;
  final String awards;
  final String? nextAvailableSlot;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.yearsOfExperience,
    required this.hospitalAffiliation,
    required this.rating,
    required this.languagesSpoken,
    required this.consultationFee,
    required this.isAvailable,
    required this.education,
    required this.awards,
    this.nextAvailableSlot,
  });

  /// 🔄 MongoDB JSON → Doctor
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '', // MongoDB _id
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      specialization: json['specialization'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      hospitalAffiliation: json['hospitalAffiliation'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      languagesSpoken: List<String>.from(json['languagesSpoken'] ?? []),
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      education: json['education'] ?? '',
      awards: json['awards'] ?? '',
      nextAvailableSlot: json['nextAvailableSlot'],
    );
  }

  /// 🔄 Doctor → MongoDB JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
      'hospitalAffiliation': hospitalAffiliation,
      'rating': rating,
      'languagesSpoken': languagesSpoken,
      'consultationFee': consultationFee,
      'isAvailable': isAvailable,
      'education': education,
      'awards': awards,
      'nextAvailableSlot': nextAvailableSlot,
    };
  }

  /// ✅ CopyWith for updating availability/slots
  Doctor copyWith({
    bool? isAvailable,
    String? nextAvailableSlot,
  }) {
    return Doctor(
      id: id,
      name: name,
      email: email,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
      hospitalAffiliation: hospitalAffiliation,
      rating: rating,
      languagesSpoken: languagesSpoken,
      consultationFee: consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      education: education,
      awards: awards,
      nextAvailableSlot: nextAvailableSlot ?? this.nextAvailableSlot,
    );
  }

  /// ✅ Factory for an empty Doctor (prevents null errors in UI)
  factory Doctor.empty() {
    return Doctor(
      id: '',
      name: '',
      email: '',
      specialization: '',
      yearsOfExperience: 0,
      hospitalAffiliation: '',
      rating: 0.0,
      languagesSpoken: [],
      consultationFee: 0.0,
      isAvailable: true,
      education: '',
      awards: '',
      nextAvailableSlot: null,
    );
  }

  /// ✅ Getters for widget compatibility
  String get avatarIcon => name.isNotEmpty ? name[0].toUpperCase() : '?';
  String get specialty => specialization;
  int get experience => yearsOfExperience;
  String? get nextAvailable => nextAvailableSlot;
}
