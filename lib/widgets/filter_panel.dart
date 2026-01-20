// lib/widgets/filter_panel.dart
import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final ValueChanged<String> onSpecialtyChanged;
  final ValueChanged<String> onAvailabilityChanged;
  final ValueChanged<int> onExperienceChanged;

  FilterPanel({
    required this.onSpecialtyChanged,
    required this.onAvailabilityChanged,
    required this.onExperienceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Specialty Filter
            _buildFilterDropdown(
              'Specialty',
              ['All', 'Cardiology', 'Neurology', 'Orthopedics', 'Pediatrics', 'Dermatology'],
              onSpecialtyChanged,
            ),
            SizedBox(width: 12),
            
            // Availability Filter
            _buildFilterDropdown(
              'Availability',
              ['All', 'Morning', 'Afternoon', 'Evening'],
              onAvailabilityChanged,
            ),
            SizedBox(width: 12),
            
            // Experience Filter
            _buildFilterDropdown(
              'Experience',
              ['All', '5+ years', '10+ years', '15+ years'],
              (value) {
                int years = 0;
                if (value == '5+ years') years = 5;
                if (value == '10+ years') years = 10;
                if (value == '15+ years') years = 15;
                onExperienceChanged(years);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> options,
    ValueChanged<String> onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.first,
              onChanged: (value) => onChange(value!),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}