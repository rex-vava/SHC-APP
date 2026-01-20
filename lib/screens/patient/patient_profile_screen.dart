
import 'package:flutter/material.dart';
import 'package:shc_app/screens/patient/edit_insurance_screen.dart';

class PatientModel {
  final String name;
  final String email;
  final String phone;
  final String? healthInsurance;
  const PatientModel({required this.name, required this.email, required this.phone, this.healthInsurance});
}

class PatientProfileScreen extends StatelessWidget {
  final PatientModel patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: Text(patient.name),
                subtitle: const Text('Name'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(patient.email),
                subtitle: const Text('Email'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(patient.phone),
                subtitle: const Text('Phone'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Health Insurance'),
                subtitle: Text(patient.healthInsurance ?? 'Not set'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditInsuranceScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
