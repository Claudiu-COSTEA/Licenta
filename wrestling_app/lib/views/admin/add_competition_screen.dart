import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';
import 'map_picker_screen.dart';
import 'package:intl/intl.dart'; // For formatting date & time
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
  final admin = AdminServices();
  bool _isLoading = false;
  static const Color primaryColor = Color(0xFFB4182D);

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
    // 1. Validare
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      ToastHelper.eroare('Date incomplete !');
      return;
    }

    setState(() => _isLoading = true);

    // 2. Un singur apel către API
    final ServiceResult res = await admin.addCompetition(
      name: _nameController.text.trim(),
      startDate: _startDateController.text.trim(), // „YYYY-MM-DD HH:MM:SS”
      endDate: _endDateController.text.trim(),
      location:
      '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
    );

    setState(() => _isLoading = false);

    if (!mounted) return; // dacă widget-ul a fost scos din arbore

    // 3. Afișează toast în funcție de rezultat
    if (res.success) {
      ToastHelper.succes('Competiție adăugată cu succes !');
      Navigator.pop(context); // opțional: întoarce-te după succes
    } else {
      ToastHelper.eroare('Eroare la adăugare!');
    }
  }

  Widget _infoLocatie() {
    if (_selectedLocation == null) {
      return const Text(
        'Alege locația competiției',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    final lat = _selectedLocation!.latitude.toStringAsFixed(5);   // max 5 zecimale
    final lng = _selectedLocation!.longitude.toStringAsFixed(5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.location_on, color: Colors.white, size: 18),
        const SizedBox(width: 4),
        Text(
          'Lat: $lat,  Lon: $lng',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // În loc de Column + Expanded, folosim SingleChildScrollView
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Center(
                child: Text(
                  "Adăugare competiții",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
                ),
              ),

              const SizedBox(height: 20,),
              // ─── Form ──────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Denumire competiție
                    const Text(
                      "Denumirea competiției",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Introduce-ți denumirea competiției",
                        hintStyle: const TextStyle(color: primaryColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Vă rog introduce-ți denumirea competiției"
                          : null,
                      style: const TextStyle(color: primaryColor),
                    ),
                    const SizedBox(height: 24),

                    // Data început
                    const Text(
                      "Dată început",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: _pickStartDate,
                      decoration: InputDecoration(
                        hintText: "Selectează dată și oră de început",
                        suffixIcon: const Icon(Icons.calendar_today),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Selectează dată și oră de început"
                          : null,
                      style: const TextStyle(color: primaryColor),
                    ),
                    const SizedBox(height: 24),

                    // Data sfârșit
                    const Text(
                      "Dată sfârșit",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: _pickEndDate,
                      decoration: InputDecoration(
                        hintText: "Selectează dată și oră de sfârșit",
                        suffixIcon: const Icon(Icons.calendar_today),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Selectează dată și oră de sfârșit"
                          : null,
                      style: const TextStyle(color: primaryColor),
                    ),
                    const SizedBox(height: 30),

                    // Picker locație
                    Center(
                      child: ElevatedButton(
                        onPressed: _pickLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // Aceasta va centra conținutul butonului
                          alignment: Alignment.center,
                        ),
                        // În loc de ElevatedButton.icon(...), folosim child = Row(...)
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8),
                            _infoLocatie(), // deja returnează un Text cu stilul dorit
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Buton „Adaugă competiție”
                    _isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Adaugă competiție",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Logo la final (în interiorul aceluiași scroll) ───
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/wrestling_logo.png',
                      height: 300,
                      fit: BoxFit.contain,
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
}
