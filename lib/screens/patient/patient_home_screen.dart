import 'package:flutter/material.dart';
import '../../services/doctor_service.dart';
import '../../services/appointment_service.dart';
import '../../models/doctor_model.dart';
import '../../models/patient_model.dart';
import '../../models/appointment_model.dart';
import 'booking_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final PatientModel currentPatient;
  const PatientHomeScreen({Key? key, required this.currentPatient}) : super(key: key);

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoadingDoctors = true;
  String? _doctorError;

  List<AppointmentModel> _appointments = [];
  bool _isLoadingAppointments = true;
  String? _appointmentError;

  String _selectedSpecialization = 'All';
  double _minRating = 0.0;
  List<String> _availableSpecializations = ['All'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadAppointments();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoadingDoctors = true;
      _doctorError = null;
    });
    try {
      final doctors = await DoctorService.getDoctors();
      final specializations = doctors.map((d) => d.specialization).toSet().toList();
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _availableSpecializations = ['All', ...specializations];
        _isLoadingDoctors = false;
      });
    } catch (e) {
      setState(() {
        _doctorError = 'Failed to load doctors: $e';
        _isLoadingDoctors = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoadingAppointments = true;
      _appointmentError = null;
    });
    try {
      final appointments = await AppointmentService.getAppointmentsByPatient(widget.currentPatient.token, widget.currentPatient.id);
      setState(() {
        _appointments = appointments;
        _isLoadingAppointments = false;
      });
    } catch (e) {
      setState(() {
        _appointmentError = 'Failed to load appointments: $e';
        _isLoadingAppointments = false;
      });
    }
  }

  void _applyFilters() {
    List<Doctor> filtered = _doctors;
    if (_selectedSpecialization != 'All') filtered = filtered.where((d) => d.specialization == _selectedSpecialization).toList();
    if (_minRating > 0) filtered = filtered.where((d) => d.rating >= _minRating).toList();
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((d) =>
          d.name.toLowerCase().contains(query) ||
          d.specialization.toLowerCase().contains(query) ||
          d.hospitalAffiliation.toLowerCase().contains(query) ||
          d.languagesSpoken.any((lang) => lang.toLowerCase().contains(query))).toList();
    }
    setState(() => _filteredDoctors = filtered);
  }

  void _showDoctorDetails(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DoctorDetailsBottomSheet(
        doctor: doctor,
        currentPatient: widget.currentPatient,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getTitle(_currentIndex)), backgroundColor: Colors.blue),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Doctors'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Book'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  List<Widget> get _screens => [
        _buildDoctorListScreen(),
        _buildProfileScreen(),
        _buildBookingScreen(),
        _buildAppointmentHistoryScreen(),
        _buildSettingsScreen(),
      ];

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Available Doctors';
      case 1:
        return 'Profile';
      case 2:
        return 'Book Appointment';
      case 3:
        return 'Appointment History';
      case 4:
        return 'Settings';
      default:
        return 'Patient Dashboard';
    }
  }

  Widget _buildDoctorListScreen() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search doctors, hospitals, languages...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSpecialization,
                  items: _availableSpecializations
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _selectedSpecialization = val);
                    _applyFilters();
                  },
                  decoration: const InputDecoration(labelText: 'Specialization'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Minimum rating'),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: _minRating.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _minRating = v),
                      onChangeEnd: (_) => _applyFilters(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoadingDoctors
                ? const Center(child: CircularProgressIndicator())
                : _doctorError != null
                    ? Center(child: Text(_doctorError!))
                    : _filteredDoctors.isEmpty
                        ? const Center(child: Text('No doctors found.'))
                        : RefreshIndicator(
                            onRefresh: _loadDoctors,
                            child: ListView.builder(
                              itemCount: _filteredDoctors.length,
                              itemBuilder: (context, index) {
                                final doctor = _filteredDoctors[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: CircleAvatar(child: Text(doctor.name.isNotEmpty ? doctor.name[0] : '?')),
                                    title: Text(doctor.name),
                                    subtitle: Text('${doctor.specialization} • ${doctor.hospitalAffiliation}'),
                                    trailing: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text(doctor.rating.toStringAsFixed(1)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () => _showDoctorDetails(doctor),
                                          child: const Text('View'),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showDoctorDetails(doctor),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingScreen() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingScreen(
                doctor: _doctors.isNotEmpty ? _doctors.first : Doctor.empty(),
                currentPatient: widget.currentPatient,
                token: widget.currentPatient.token,
              ),
            ),
          );
        },
        child: const Text('Book a New Appointment'),
      ),
    );
  }

  Widget _buildProfileScreen() {
    final p = widget.currentPatient;
    final idStr = '${p.id}';
    final avatarChar = idStr.isNotEmpty ? idStr[0] : '?';
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 40, child: Text(avatarChar, style: const TextStyle(fontSize: 24))),
          const SizedBox(height: 12),
          Text('Patient ID: $idStr'),
          const SizedBox(height: 8),
          Text('Details: ${p.toString()}'),
        ],
      ),
    );
  }

  Widget _buildAppointmentHistoryScreen() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: _isLoadingAppointments
          ? const Center(child: CircularProgressIndicator())
          : _appointmentError != null
              ? Center(child: Text(_appointmentError!))
              : _appointments.isEmpty
                  ? const Center(child: Text('No appointments found.'))
                  : ListView.builder(
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text('Appointment with Doctor ${appointment.doctorId}'),
                            subtitle: Text('${appointment.appointmentDate.toLocal().toString().split(' ')[0]} at ${appointment.appointmentTime}'),
                            trailing: Text(appointment.status.toString().split('.').last),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildSettingsScreen() {
    return const Center(
      child: Text('Settings Screen - Coming Soon'),
    );
  }
}

class DoctorDetailsBottomSheet extends StatelessWidget {
  final Doctor doctor;
  final PatientModel currentPatient;

  const DoctorDetailsBottomSheet({
    Key? key,
    required this.doctor,
    required this.currentPatient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(doctor.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${doctor.specialization} at ${doctor.hospitalAffiliation}'),
          const SizedBox(height: 8),
          Text('Rating: ${doctor.rating.toStringAsFixed(1)}'),
          const SizedBox(height: 8),
          Text('Languages: ${doctor.languagesSpoken.join(', ')}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(
                    doctor: doctor,
                    currentPatient: currentPatient,
                    token: currentPatient.token,
                  ),
                ),
              );
            },
            child: const Text('Book Appointment'),
          ),
        ],
      ),
    );
  }
}
