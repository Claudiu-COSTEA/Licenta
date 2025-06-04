// file: lib/screens/invitations/invitation_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/views/admin/referees_invitations_screen.dart';
import 'package:wrestling_app/views/admin/wrestling_clubs_invitations_screen.dart';
import '../../models/competition_model.dart';
import '../../services/admin_apis_services.dart';

class SendInvitationScreen extends StatefulWidget {
  const SendInvitationScreen({Key? key}) : super(key: key);

  @override
  State<SendInvitationScreen> createState() => _SendInvitationScreen();
}

class _SendInvitationScreen extends State<SendInvitationScreen> {
  final _admin = AdminServices();
  List<Competition> _competitions = [];
  Competition? _selected;
  bool _loading = true;

  static const Color primary = Color(0xFFB4182D);

  @override
  void initState() {
    super.initState();
    _loadComps();
  }

  Future<void> _loadComps() async {
    try {
      _competitions = await _admin.fetchCompetitions();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // card generic
  Widget _card({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  // navighează către ecranele tale de listă
  void _goTo(String routeName) {
    if (_selected == null) return;
    Navigator.pushNamed(
      context,
      routeName,
      arguments: {"competitionUUID": _selected!.uuid},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trimite invitaţii',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //── dropdown competiții
            DropdownButtonFormField<Competition>(
              decoration: const InputDecoration(
                labelText: 'Alege competiţia',
                border: OutlineInputBorder(),
              ),
              value: _selected,
              items: _competitions.map((c) {
                final date = DateFormat('yyyy-MM-dd').format(c.startDate);
                return DropdownMenuItem(
                  value: c,
                  child: Text('${c.name} ($date)'),
                );
              }).toList(),
              onChanged: (c) => setState(() => _selected = c),
              validator: (c) => c == null ? 'Selectează competiţia' : null,
            ),
            const SizedBox(height: 24),

            //── grid cu 4 card-uri
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 4 / 3,
                children: [
                  // În loc de _goTo('/clubs')
                  _card(
                    icon : Icons.groups,
                    label: 'Cluburi sportive',
                    onTap: _selected == null
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClubsListScreen(
                            competitionUUID: _selected!.uuid,   // ← UUID ales
                          ),
                        ),
                      );
                    },
                  ),

                  _card(
                    icon: Icons.gavel,
                    label: 'Arbitri',
                    onTap:
                    _selected == null ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RefereesListScreen(
                            competitionUUID: _selected!.uuid,   // ← UUID ales
                          ),
                        ),
                      );
                    },
                  ),
                  _card(
                    icon: Icons.school,
                    label: 'Antrenori',
                    onTap: _selected == null
                        ? null
                        : () => _goTo('/coaches'),
                  ),
                  _card(
                    icon: Icons.fitness_center,
                    label: 'Luptători',
                    onTap: _selected == null
                        ? null
                        : () => _goTo('/wrestlers'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
