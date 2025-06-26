// file: lib/screens/invitations/invitation_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/views/admin/referees_invitations_screen.dart';
import 'package:wrestling_app/views/admin/wrestlers_invitations_screen.dart';
import 'package:wrestling_app/views/admin/wrestling_clubs_invitations_screen.dart';
import '../../models/competition_model.dart';
import '../../services/admin_apis_services.dart';
import '../shared/widgets/toast_helper.dart';
import 'coaches_invitations_screen.dart';

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
    } catch (e) {
      ToastHelper.eroare('Nu am putut încărca competițiile');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // card generic
  Widget _card({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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

  void _handleCardTap(Function navigate) {
    if (_selected == null) {
      ToastHelper.eroare('Te rog, selectează mai întâi o competiție.');
    } else {
      navigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: primary,))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const SizedBox(height: 30,),

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
                "Trimitere invitații",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ),

            const SizedBox(height: 20,),

            //── dropdown competiții
            DropdownButtonFormField<Competition>(
              decoration: InputDecoration(
                labelText: 'Alege competiția',
                labelStyle: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: primary,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: primary,
                    width: 2.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              iconEnabledColor: primary, // culoarea iconiței
              dropdownColor: Colors.white, // fundalul listei derulante
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              value: _selected,
              items: _competitions.map((c) {
                final date =
                DateFormat('yyyy-MM-dd').format(c.competitionStartDate);
                return DropdownMenuItem(
                  value: c,
                  child: Text(
                    '${c.competitionName} ($date)',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (c) => setState(() => _selected = c),
              validator: (c) => c == null ? 'Selectează competiția' : null,
            ),
            const SizedBox(height: 20),

            //── grid cu 4 card-uri
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 4 / 3,
                children: [
                  _card(
                    icon: Icons.groups,
                    label: 'Cluburi sportive',
                    onTap: () => _handleCardTap(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClubsListScreen(
                            competitionUUID: _selected!.competitionUUID,
                          ),
                        ),
                      );
                    }),
                  ),

                  _card(
                    icon: Icons.gavel,
                    label: 'Arbitri',
                    onTap: () => _handleCardTap(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RefereesListScreen(
                            competitionUUID: _selected!.competitionUUID,
                          ),
                        ),
                      );
                    }),
                  ),

                  _card(
                    icon: Icons.school,
                    label: 'Antrenori',
                    onTap: () => _handleCardTap(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CoachesListScreen(
                            competitionUUID: _selected!.competitionUUID,
                          ),
                        ),
                      );
                    }),
                  ),

                  _card(
                    icon: Icons.fitness_center,
                    label: 'Luptători',
                    onTap: () => _handleCardTap(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WrestlersListScreen(
                            competitionUUID: _selected!.competitionUUID,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/wrestling_logo.png',
                      height: 280,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
