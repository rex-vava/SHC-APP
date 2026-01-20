// lib/widgets/booking_dialog.dart
import 'package:flutter/material.dart';
import 'package:shc_app/models/doctor_model.dart' show Doctor;


class BookingDialog extends StatefulWidget {
  final Doctor doctor;

  BookingDialog({required this.doctor});

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomsController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166088),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              
              // Doctor Info
              ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFd1e8ff),
                  child: Text(widget.doctor.avatarIcon),
                ),
                title: Text(
                  widget.doctor.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(widget.doctor.specialty),
              ),
              
              SizedBox(height: 24),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Date Picker
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 60)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Color(0xFF4a6fa5)),
                            SizedBox(width: 12),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Select date',
                              style: TextStyle(
                                color: _selectedDate != null ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Time Slot Picker
                    Text(
                      'Select Time Slot:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['09:00 AM', '10:30 AM', '02:00 PM', '03:30 PM', '05:00 PM']
                          .map((time) => ChoiceChip(
                                label: Text(time),
                                selected: _selectedTime == time,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTime = selected ? time : null;
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Symptoms/Reason
                    TextFormField(
                      controller: _symptomsController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Symptoms / Reason for Visit',
                        border: OutlineInputBorder(),
                        hintText: 'Describe your symptoms or reason for appointment...',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe your symptoms';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate() &&
                                  _selectedDate != null &&
                                  _selectedTime != null) {
                                // Handle booking logic here
                                _showConfirmation();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fill all fields'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF166088),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('Confirm Booking'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Appointment Booked!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your appointment with ${widget.doctor.name} has been confirmed.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'You will receive a confirmation email with details.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation
              Navigator.pop(context); // Close booking dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}