// lib/screens/doctor/doctor_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../models/patient_model.dart';
import '../../services/appointment_service.dart';
import '../../services/doctor_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  late Future<List<AppointmentModel>> _futureAppointments;
  late Future<Doctor?> _futureDoctorProfile;

  String _selectedFilter = 'All'; // 'All', 'Today', 'Upcoming', 'Pending'
  int _selectedTabIndex = 0; // 0: Appointments, 1: Patients, 2: Profile

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadDoctorProfile();
  }

  void _loadAppointments() {
    final auth = context.read<AuthProvider>();
    _futureAppointments = AppointmentService.getAppointmentsByDoctor(
      token: auth.token!,
      doctorId: auth.user!.id,
    );
  }

  void _loadDoctorProfile() {
    final auth = context.read<AuthProvider>();
    _futureDoctorProfile =
        DoctorService.getDoctorProfileByUserId(auth.user!.id);
  }

  List<PatientModel> _extractPatientsFromAppointments(
      List<AppointmentModel> appointments) {
    final Map<String, PatientModel> patientMap = {};
    final auth = context.read<AuthProvider>();

    for (final appt in appointments) {
      if (!patientMap.containsKey(appt.patientId)) {
        patientMap[appt.patientId] = PatientModel(
          id: appt.patientId,
          name: appt.patientName,
          email: appt.patientEmail,
          phone: appt.patientPhone ?? 'Not provided',
          healthInsurance: appt.patientHealthInsurance ?? 'Not provided',
          age: appt.patientAge?.toString() ?? 'Unknown',
          gender: appt.patientGender ?? 'Not specified',
          medicalHistory: appt.patientMedicalHistory ?? 'No history provided',
          token: auth.token ?? '',
        );
      }
    }

    return patientMap.values.toList();
  }

  Widget _appointmentsTab() {
    return FutureBuilder<List<AppointmentModel>>(
      future: _futureAppointments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No appointments found.'));
        }

        final appointments = snapshot.data!;
        List<AppointmentModel> filteredAppointments = appointments;

        if (_selectedFilter != 'All') {
          filteredAppointments = appointments.where((appt) {
            final now = DateTime.now();
            if (_selectedFilter == 'Today') {
              return appt.date.year == now.year &&
                  appt.date.month == now.month &&
                  appt.date.day == now.day;
            } else if (_selectedFilter == 'Upcoming') {
              return appt.date.isAfter(now);
            } else if (_selectedFilter == 'Pending') {
              return appt.status.toLowerCase() == 'pending';
            }
            return true;
          }).toList();
        }

        return Column(
          children: [
            DropdownButton<String>(
              value: _selectedFilter,
              items: ['All', 'Today', 'Upcoming', 'Pending']
                  .map((filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredAppointments.length,
                itemBuilder: (context, index) {
                  final appt = filteredAppointments[index];
                  return ListTile(
                    title: Text(appt.patientName),
                    subtitle: Text(
                        '${appt.date.toLocal()} - Status: ${appt.status}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _patientsTab() {
    return FutureBuilder<List<AppointmentModel>>(
      future: _futureAppointments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No patients found.'));
        }

        final patients = _extractPatientsFromAppointments(snapshot.data!);
        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return ListTile(
              title: Text(patient.name),
              subtitle: Text(patient.email),
            );
          },
        );
      },
    );
  }

  Widget _profileTab() {
    return FutureBuilder<Doctor?>(
      future: _futureDoctorProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Profile not found.'));
        }

        final doctor = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${doctor.name}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Specialization: ${doctor.specialization}'),
              const SizedBox(height: 8),
              Text('Email: ${doctor.email}'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _appointmentsTab(),
      _patientsTab(),
      _profileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Home'),
      ),
      body: tabs[_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
