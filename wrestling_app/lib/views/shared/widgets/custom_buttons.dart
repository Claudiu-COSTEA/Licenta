import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Custom Button Widget
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: Color(0xFFB4182D),
        elevation: 5,
      ),
      child: Text(
        widget.label,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}

// Custom Dropdown Widget
class CustomDropdown extends StatefulWidget {
  const CustomDropdown({super.key});

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> {
  final List<String> options = [
    "Option 1",
    "Option 2",
    "Option 3",
    "Option 4",
    "Option 5",
    "Option 6",
    "Option 7",
    "Option 8",
    "Option 9",
    "Option 10",
  ];

  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecteaza categoria de greutate',  // The label text above the dropdown
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),  // Space between the label and the dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            filled: true,
            fillColor: Color(0xFFB4182D), // Red background for the dropdown
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          dropdownColor: Color(0xFFB4182D), // White background for dropdown items
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), // Black text for items
          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
          value: selectedOption,
          hint: Text('Choose an option', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedOption = newValue;
              if (kDebugMode) {
                print('Selected: $selectedOption');
              }
            });
          },
        ),
      ],
    );
  }
}


