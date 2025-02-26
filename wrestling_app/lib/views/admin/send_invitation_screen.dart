import 'package:flutter/material.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';

class SendInvitationScreen extends StatefulWidget {
  const SendInvitationScreen({super.key});

  @override
  State<SendInvitationScreen> createState() => _SendInvitationScreenState();
}

class _SendInvitationScreenState extends State<SendInvitationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _competitionUUIDController = TextEditingController();
  final TextEditingController _recipientUUIDController = TextEditingController();
  final TextEditingController _invitationDeadlineController = TextEditingController();
  final TextEditingController _weightCategoryController = TextEditingController();
  String _selectedRole = 'Coach'; // Default role
  bool _isLoading = false;
  final AdminServices _invitationService = AdminServices();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await _invitationService.sendInvitation(
      competitionUUID: int.parse(_competitionUUIDController.text.trim()),
      recipientUUID: int.parse(_recipientUUIDController.text.trim()),
      recipientRole: _selectedRole,
      weightCategory: _selectedRole == 'Wrestler' ? _weightCategoryController.text.trim() : null,
      invitationStatus: 'Pending', // Default status
      invitationDeadline: _invitationDeadlineController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation sent successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send invitation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const Center(
                  child: Text(
                    "Send Invitation",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),

                _buildTextField(_competitionUUIDController, "Competition UUID", "Enter competition ID"),
                _buildTextField(_recipientUUIDController, "Recipient UUID", "Enter recipient ID"),
                _buildTextField(_invitationDeadlineController, "Invitation Deadline", "YYYY-MM-DD HH:MM:SS"),

                const SizedBox(height: 10),
                const Text("Select Role"),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: ['Wrestling Club', 'Referee', 'Coach', 'Wrestler']
                      .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 10),
                if (_selectedRole == 'Wrestler')
                  _buildTextField(_weightCategoryController, "Weight Category", "Enter weight category"),

                const SizedBox(height: 20),
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
                      "Send Invitation",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? "Field cannot be empty" : null,
      ),
    );
  }
}
