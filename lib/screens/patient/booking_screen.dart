import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../models/patient_model.dart';
import '../../services/appointment_service.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  final PatientModel currentPatient;
  final String token;

  const BookingScreen({
    Key? key,
    required this.doctor,
    required this.currentPatient,
    required this.token,
  }) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.medical_services, size: 40, color: Colors.blue),
                title: Text('Dr. ${widget.doctor.name}'),
                subtitle: Text('${widget.doctor.specialization} • ${widget.doctor.hospitalAffiliation}'),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(_selectedDate != null
                  ? 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Select Date'),
              onTap: _pickDate,
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.blue),
              title: Text(_selectedTime != null
                  ? 'Time: ${_selectedTime!.format(context)}'
                  : 'Select Time'),
              onTap: _pickTime,
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                  labelText: 'Notes / Reason for visit', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAppointment,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Book Appointment'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      setState(() => _error = 'Please select both date and time');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      await AppointmentService.bookAppointment(
        token: widget.token,
        doctorId: widget.doctor.id,
        patientId: widget.currentPatient.id,
        notes: _notesController.text,
      );

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = 'Failed to book appointment: $e';
      });
    }
  }
}
