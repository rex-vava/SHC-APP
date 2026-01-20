
import 'package:flutter/material.dart';

class MyProfileScreen extends StatelessWidget {
  final String doctorId;
  final String token;

  const MyProfileScreen({
    super.key,
    required this.doctorId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: const Center(child: Text('Doctor profile will be shown here')),
    );
  }
}