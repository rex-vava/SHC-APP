import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _mutuelleNumberController = TextEditingController();

  // State variables
  String _selectedUserType = 'patient';
  String? _selectedGender;
  String? _selectedSpecialization;
  String? _selectedHealthInsurance;
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Constants
  static const List<String> userTypes = ['patient', 'doctor'];
  static const List<String> genders = ['male', 'female', 'other'];
  static const List<String> specializations = [
    'General Practitioner',
    'Pediatrician',
    'Gynecologist',
    'Cardiologist',
    'Dermatologist',
    'Psychiatrist',
    'Dentist',
    'Orthopedic',
    'Neurologist',
    'Other'
  ];
  static const List<String> healthInsuranceOptions = [
    'RAMA',
    'MMI',
    'Mutuelle de Santé',
    'Other',
    'None'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    
    // Clean the input (remove spaces, dashes, etc.)
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]+'), '');
    
    if (!RegExp(r'^(078|079|072|073)\d{7}$').hasMatch(cleanPhone)) {
      return 'Enter a valid Rwanda phone number (078/079/072/073 XXXXXXX)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  try {
    final result = await authProvider.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      userType: _selectedUserType,
      nationalId: _nationalIdController.text.trim().isEmpty
          ? null
          : _nationalIdController.text.trim(),
      dateOfBirth: _selectedDate?.toIso8601String(),
      gender: _selectedGender,
      licenseNumber: _selectedUserType == 'doctor'
          ? _licenseNumberController.text.trim()
          : null,
      specialization:
          _selectedUserType == 'doctor' ? _selectedSpecialization : null,
      
    );

    if (result['success'] == true) {
      _formKey.currentState?.reset();

      if (_selectedUserType == 'patient') {
        Navigator.pushReplacementNamed(context, '/patient-home');
      } else {
        Navigator.pushReplacementNamed(context, '/doctor-home');
      }
    } else {
      _showErrorSnackBar(result['message'] ?? 'Registration failed');
    }
  } catch (e) {
    _showErrorSnackBar('An error occurred: $e');
  }
}


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildUserTypeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'I am a:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: userTypes.map((type) {
                return Expanded(
                  child: Card(
                    elevation: 0,
                    color: _selectedUserType == type
                        ? Theme.of(context).primaryColor.withAlpha((0.1 * 255).round())
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _selectedUserType == type 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          _selectedUserType = type;
                          // Clear doctor-specific fields when switching to patient
                          if (type == 'patient') {
                            _licenseNumberController.clear();
                            _selectedSpecialization = null;
                          }
                          // Clear patient-specific fields when switching to doctor
                          if (type == 'doctor') {
                            _selectedHealthInsurance = null;
                            _mutuelleNumberController.clear();
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type == 'patient' ? Icons.person : Icons.medical_services,
                              color: _selectedUserType == type 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type == 'patient' ? 'Patient' : 'Doctor',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _selectedUserType == type 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                color: _selectedUserType == type 
                                    ? Theme.of(context).primaryColor 
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ?? (value) => isRequired ? _validateRequired(value, label) : null,
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              hintText: 'example@gmail.com',
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hintText: '0781234567',
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nationalIdController,
              label: 'National ID',
              icon: Icons.badge_outlined,
              isRequired: false,
              keyboardType: TextInputType.number,
              hintText: '123456789012345',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: const Icon(Icons.transgender),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              items: genders
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(
                          gender[0].toUpperCase() + gender.substring(1),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              hint: const Text('Select gender'),
              isExpanded: true,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select date',
                      style: TextStyle(
                        color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _licenseNumberController,
              label: 'Medical License Number',
              icon: Icons.medical_services_outlined,
              hintText: 'e.g., MED-123456',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecialization,
              decoration: InputDecoration(
                labelText: 'Specialization *',
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              items: specializations
                  .map((specialty) => DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      ))
                  .toList(),
              validator: (value) => _validateRequired(value, 'Specialization'),
              onChanged: (value) {
                setState(() {
                  _selectedSpecialization = value;
                });
              },
              hint: const Text('Select specialization'),
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Insurance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedHealthInsurance,
              decoration: InputDecoration(
                labelText: 'Select Health Insurance *',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              items: healthInsuranceOptions
                  .map((insurance) => DropdownMenuItem(
                        value: insurance,
                        child: Text(insurance),
                      ))
                  .toList(),
              validator: (value) => _validateRequired(value, 'Health insurance'),
              onChanged: (value) {
                setState(() {
                  _selectedHealthInsurance = value;
                  if (value != 'Mutuelle de Santé') {
                    _mutuelleNumberController.clear();
                  }
                });
              },
              hint: const Text('Select insurance'),
              isExpanded: true,
            ),
            if (_selectedHealthInsurance == 'Mutuelle de Santé') ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _mutuelleNumberController,
                label: 'Mutuelle Membership Number',
                icon: Icons.health_and_safety_outlined,
                hintText: 'e.g., MUT-001234',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              validator: _validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword 
                      ? Icons.visibility_outlined 
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '• At least 8 characters\n• One uppercase letter\n• One lowercase letter\n• One number',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserTypeCard(),
              const SizedBox(height: 24),
              _buildPersonalInfoCard(),
              const SizedBox(height: 24),
              if (_selectedUserType == 'doctor') _buildDoctorInfoCard(),
              if (_selectedUserType == 'patient') _buildPatientInfoCard(),
              if (_selectedUserType == 'patient' || _selectedUserType == 'doctor') 
                const SizedBox(height: 24),
              _buildSecurityCard(),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    _mutuelleNumberController.dispose();
    super.dispose();
  }
}