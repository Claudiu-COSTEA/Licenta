import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/models/competition_model.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';

class SendInvitationScreen extends StatefulWidget {
  const SendInvitationScreen({super.key});

  @override
  State<SendInvitationScreen> createState() => _SendInvitationScreenState();
}

class _SendInvitationScreenState extends State<SendInvitationScreen> {
  final _formKey = GlobalKey<FormState>();
  Competition? _selectedCompetition;
  List<Competition> _competitions = [];
  final TextEditingController _recipientUUIDController = TextEditingController();
  final TextEditingController _invitationDeadlineController = TextEditingController();
  final TextEditingController _weightCategoryController = TextEditingController();
  String _selectedRole = 'Coach';
  bool _isLoading = false;
  bool _loadingComps = true;
  final admin = AdminServices();
  final Color primaryColor = const Color(0xFFB4182D);

  @override
  void initState() {
    super.initState();
    _loadCompetitions();
  }

  Future<void> _loadCompetitions() async {
    try {
      final comps = await admin.fetchCompetitions();
      setState(() {
        _competitions = comps;
        _loadingComps = false;
      });
    } catch (e) {
      setState(() => _loadingComps = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Eroare încărcare competiții: $e')));
    }
  }

  Future<void> _pickInvitationDeadline() async {
    DateTime? pickedDate = await showDatePicker(
        context: context, initialDate: DateTime.now(),
        firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (pickedDate == null) return;
    TimeOfDay? pickedTime = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null) return;
    final combined = DateTime(
        pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute);
    _invitationDeadlineController.text =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedCompetition == null) {
      return;
    }
    setState(() => _isLoading = true);

    final ServiceResult res = await admin.sendInvitation(
      competitionUUID: _selectedCompetition!.uuid,
      recipientUUID: int.parse(_recipientUUIDController.text.trim()),
      recipientRole: _selectedRole,
      weightCategory:
      _selectedRole == 'Wrestler' ? _weightCategoryController.text.trim() : null,
      status: 'pending',                     // ex. „pending” / „accepted”
      deadline: _invitationDeadlineController.text.trim(),
    );

    setState(() => _isLoading = false);

// Afișează mesajul venit de la backend, dacă există.
    final snack = SnackBar(
      content: Text(
        res.message ??
            (res.success
                ? 'Invitation sent successfully!'
                : 'Failed to send invitation.'),
      ),
      backgroundColor: res.success ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snack);

    if (res.success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Center(
                      child: Text("Send Invitation",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 20),

                  // 1) Dropdown pentru competiții
                  _loadingComps
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<Competition>(
                    decoration: const InputDecoration(
                      labelText: 'Competiție',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCompetition,
                    items: _competitions.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text('${c.name} (${DateFormat('yyyy-MM-dd').format(c.startDate)})'),
                      );
                    }).toList(),
                    onChanged: (c) => setState(() => _selectedCompetition = c),
                    validator: (c) => c == null ? 'Alege competiția' : null,
                  ),

                  // 2) Afișează detalii competiție selecționată
                  if (_selectedCompetition != null)
                    Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        _buildRow('Denumire : ', _selectedCompetition!.name),
                        _buildRow('Începe : ', DateFormat('yyyy-MM-dd').format(_selectedCompetition!.startDate)),
                        _buildRow('Se termină : ', DateFormat('yyyy-MM-dd').format(_selectedCompetition!.endDate)),
                        _buildRow('Locație : ', _selectedCompetition!.location),
                        _buildRow('Status : ', _selectedCompetition!.status),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // 3) Recipient UUID (poți înlocui cu un selector similar)
                  _buildTextField(_recipientUUIDController, "Recipient UUID", "Enter recipient ID"),

                  const SizedBox(height: 10),
                  const Text("Invitation Deadline"),
                  TextFormField(
                    controller: _invitationDeadlineController,
                    readOnly: true,
                    onTap: _pickInvitationDeadline,
                    decoration: InputDecoration(
                      hintText: "Select Deadline Date & Time",
                      suffixIcon: const Icon(Icons.calendar_today),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor, width: 2)),
                    ),
                    validator: (v) => v!.isEmpty ? "Select invitation deadline" : null,
                  ),

                  const SizedBox(height: 10),
                  const Text("Select Role"),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: ['Wrestling Club','Referee','Coach','Wrestler']
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedRole = val!),
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
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Send Invitation",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ]),
              ))),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label, hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (v) => v!.isEmpty ? "Field cannot be empty" : null,
      ),
    );
  }

  TableRow _buildRow(String left, String right) {
    return TableRow(children: [
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(left, style: const TextStyle(fontWeight: FontWeight.bold))),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(right)),
    ]);
  }
}
