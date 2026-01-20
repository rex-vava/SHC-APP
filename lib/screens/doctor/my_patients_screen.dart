
import 'package:flutter/material.dart';

class MyPatientsScreen extends StatelessWidget {
  final String doctorId;
  final String token;

  const MyPatientsScreen({
    super.key,
    required this.doctorId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Patients')),
      body: const Center(child: Text('Patients list will be shown here')),
    );
  }
}