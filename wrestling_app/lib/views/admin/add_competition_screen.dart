import 'package:flutter/material.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';
import 'package:wrestling_app/services/auth_service.dart';

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
  final TextEditingController _locationController = TextEditingController();
  final AdminServices _competitionService = AdminServices();

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _competitionService.addCompetition(
      competitionName: _nameController.text.trim(),
      competitionStartDate: _startDateController.text.trim(),
      competitionEndDate: _endDateController.text.trim(),
      competitionLocation: _locationController.text.trim(), context: context,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Competition added successfully!')),
      );
      Navigator.pop(context); // Go back after success
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
                  Navigator.pop(context); // Go back to the previous screen
                },
              ),
            ),

            // Title
            const Center(
              child: Text(
                "Add Competition",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text("Competition Name"),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: "Enter competition name"),
                      validator: (value) => value!.isEmpty ? "Please enter a name" : null,
                    ),
                    const SizedBox(height: 10),

                    const Text("Start Date (YYYY-MM-DD HH:MM:SS)"),
                    TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(hintText: "2025-06-10 09:00:00"),
                      validator: (value) => value!.isEmpty ? "Enter start date" : null,
                    ),
                    const SizedBox(height: 10),

                    const Text("End Date (YYYY-MM-DD HH:MM:SS)"),
                    TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(hintText: "2025-06-12 18:00:00"),
                      validator: (value) => value!.isEmpty ? "Enter end date" : null,
                    ),
                    const SizedBox(height: 10),

                    const Text("Location"),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(hintText: "Enter competition location"),
                      validator: (value) => value!.isEmpty ? "Enter location" : null,
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB4182D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Add Competition",
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
