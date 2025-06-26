import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';
import 'map_picker_screen.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/views/shared/widgets/toast_helper.dart';

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
  final AdminServices admin = AdminServices();
  bool _isLoading = false;
  static const Color primaryColor = Color(0xFFB4182D);

  Future<DateTime?> _pickDate() => showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );

  Future<TimeOfDay?> _pickTime() => showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final combined =
    DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
  }

  Future<void> _pickStartDate() async {
    final date = await _pickDate();
    if (date == null) return;
    final time = await _pickTime();
    if (time == null) return;
    _startDateController.text = _formatDateTime(date, time);
  }

  Future<void> _pickEndDate() async {
    final date = await _pickDate();
    if (date == null) return;
    final time = await _pickTime();
    if (time == null) return;
    _endDateController.text = _formatDateTime(date, time);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      ToastHelper.eroare('Datele sunt incomplete!');
      return;
    }
    setState(() => _isLoading = true);

    final res = await admin.addCompetition(
      name: _nameController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      location:
      '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (res.success) {
      ToastHelper.succes('Competiție adăugată cu succes!');
      Navigator.pop(context);
    } else {
      ToastHelper.eroare('Eroare la adăugare!');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20,),

              Center(
                child: Text(
                  "Adăugare competiție",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Competition name
                    // inside your Form’s Column:

                    const SizedBox(height: 20,),
// Competition Name

                    Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Denumirea competiției",
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: primaryColor),
                          hintText: "Introduceți denumirea competiției",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? "Câmp obligatoriu" : null,
                      ),
                    ),

                    const SizedBox(height: 20,),
// Start Date
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        onTap: _pickStartDate,
                        decoration: InputDecoration(
                          labelText: "Dată început",
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: primaryColor),
                          hintText: "Selectează data și ora",
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? "Câmp obligatoriu" : null,
                      ),
                    ),

const SizedBox(height: 20,),
// End Date
                    Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: _pickEndDate,
                        decoration: InputDecoration(
                          labelText: "Dată sfârșit",
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: primaryColor),
                          hintText: "Selectează data și ora",
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? "Câmp obligatoriu" : null,
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Location picker (full width)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.location_on, color: Colors.white,),
                        label: Text(
                          _selectedLocation == null
                              ? "Alege locația competiției"
                              : "Lat: ${_selectedLocation!.latitude.toStringAsFixed(5)}, "
                              "Lon: ${_selectedLocation!.longitude.toStringAsFixed(5)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                        ),
                        style: buttonStyle,
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Submit button (full width + icon)
                    _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.add, color: Colors.white,),
                        label: const Text(
                          "Adaugă competiție",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                        ),
                        style: buttonStyle,
                      ),
                    ),
                  ],
                ),
              ),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/wrestling_logo.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
