// lib/models/user_model.dart
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String userType; // Add this
  final String? nationalId;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? healthInsurance;
final String? mutuelleNumber;

  
  // Add a name getter for convenience
  String get name => '$firstName $lastName';

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.userType, // Make this required
    this.nationalId,
    this.profilePicture,
    this.dateOfBirth,
    this.gender,
    this.address,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.healthInsurance,
    this.mutuelleNumber,

  });

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'userType': userType,
      'nationalId': nationalId,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'healthInsurance': healthInsurance,
      'mutuelleNumber': mutuelleNumber,

    };
  }

  // Update fromJson method
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['userType'] ?? 'patient', // Add this
      nationalId: json['nationalId'],
      profilePicture: json['profilePicture'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      gender: json['gender'],
      address: json['address'],
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
          healthInsurance: json['healthInsurance'],
          mutuelleNumber: json['mutuelleNumber'],

    );
  }

  bool get isDoctor => userType.toLowerCase() == 'doctor';
  bool get isPatient => userType.toLowerCase() == 'patient';
}