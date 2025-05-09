import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';
import 'map_picker_screen.dart';
import 'package:intl/intl.dart'; // For formatting date & time

class AddCompetitionScreen extends StatefulWidget {
  const AddCompetitionScreen({super.key});

  @override
  State<AddCompetitionScreen> createState() => _AddCompetitionScreenState();
}

class _AddCompetitionScreenState extends State<AddCompetitionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  LatLng? _selectedLocation;
  final AdminServices _competitionService = AdminServices();
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFFB4182D); // Custom color

  Future<void> _pickStartDate() async {
    DateTime? pickedDate = await _pickDate();
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await _pickTime();
      if (pickedTime != null) {
        _startDateController.text = _formatDateTime(pickedDate, pickedTime);
      }
    }
  }

  Future<void> _pickEndDate() async {
    DateTime? pickedDate = await _pickDate();
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await _pickTime();
      if (pickedTime != null) {
        _endDateController.text = _formatDateTime(pickedDate, pickedTime);
      }
    }
  }

  Future<DateTime?> _pickDate() async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
  }

  Future<TimeOfDay?> _pickTime() async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    DateTime combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerScreen()),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a location')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _competitionService.addCompetition(
      competitionName: _nameController.text.trim(),
      competitionStartDate: _startDateController.text.trim(),
      competitionEndDate: _endDateController.text.trim(),
      competitionLocation: "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}",
      context: context,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Competition added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add competition.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 50),

            const Center(
              child: Text(
                "Aăugare competiție",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text("Denumirea competiției"),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Introduce-ți denumirea competiției",
                        hintStyle: TextStyle(color: primaryColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),

                      validator: (value) => value!.isEmpty
                          ? "Vă rog introduce-ți denumirea competiției"
                          : null,
                      style: TextStyle(color: primaryColor),
                    ),
                    const SizedBox(height: 30),

                    const Text("Dată început"),
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: _pickStartDate,
                      decoration: InputDecoration(
                        hintText: "Selectează dată și oră de început",
                        suffixIcon: const Icon(Icons.calendar_today),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Selectează dată și oră de început" : null,
                    ),
                    const SizedBox(height: 30),

                    const Text("Dată sfârșit"),
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: _pickEndDate,
                      decoration: InputDecoration(
                        hintText: "Selectează dată și oră de sfârșit",
                        suffixIcon: const Icon(Icons.calendar_today),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Selectează dată și oră de sfârșit" : null,
                    ),
                    const SizedBox(height: 30),

                    // Location Picker
                    ElevatedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.location_on, color: Colors.white),
                      label: Text(
                        _selectedLocation == null
                            ? "Alege locația competiției"
                            : "Locație: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Adaugă competiție",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
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
}
