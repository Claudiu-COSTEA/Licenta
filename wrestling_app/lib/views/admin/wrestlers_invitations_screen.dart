// file: lib/screens/referees_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/models/wrestler_complete_model.dart';
import '../../services/admin_apis_services.dart';
import '../shared/widgets/toast_helper.dart';

class WrestlersListScreen extends StatefulWidget {
  final int competitionUUID;
  const WrestlersListScreen({Key? key, required this.competitionUUID})
      : super(key: key);

  @override
  State<WrestlersListScreen> createState() => _WrestlersListScreen();
}

class _WrestlersListScreen extends State<WrestlersListScreen> {
  final _svc = AdminServices();

  late Future<void> _loader;
  List<WrestlerCompleteModel> _allWrestlers = [];
  final Set<int> _alreadyInvited = {};

  // ─── filtrare după stil ───
  String _selectedStyle = 'Toți';           // Toți | Greco Roman | Freestyle | Women
  List<WrestlerCompleteModel> get _visibleWrestlers {
    if (_selectedStyle == 'Toți') return _allWrestlers;
    return _allWrestlers
        .where((w) => w.style == _selectedStyle)
        .toList();
  }

  static const Color primary  = Color(0xFFB4182D);
  static const Color darkGrey = Color(0xFF444444);

  @override
  void initState() {
    super.initState();
    _loader = _loadData();
  }

  Future<void> _loadData() async {
    _allWrestlers = await _svc.fetchWrestlers();
    final invites = await _svc.fetchInvitationsByRole(
      role: 'Wrestler',
      competitionUUID: widget.competitionUUID.toString(),
    );
    _alreadyInvited
      ..clear()
      ..addAll(invites.map((e) => e.recipientUUID));
  }

  Future<void> _sendInvite(WrestlerCompleteModel wre) async {
    if (_alreadyInvited.contains(wre.uuid)) return;

    final deadline = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.now().add(const Duration(hours: 72)));

    final res = await _svc.sendInvitation(
      competitionUUID: widget.competitionUUID,
      recipientUUID: wre.uuid,
      recipientRole: 'Wrestler',
      status: 'Pending',
      deadline: deadline,
    );

    if (!mounted) return;
    if (res.success) {
      setState(() => _alreadyInvited.add(wre.uuid));
      ToastHelper.succes('Invitație trimisă!');
    } else {
      ToastHelper.eroare('Eroare la trimitere: ${res.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text('Luptători', style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.transparent),
      body: FutureBuilder<void>(
        future: _loader,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primary,));
          }
          if (snap.hasError) {
            return Center(child: Text('Eroare: ${snap.error}'));
          }

          // ─── BARĂ DE FILTRU ───
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildChip('Toți', 'Toți'),
                    _buildChip('Greco-romane', 'Greco Roman'),
                    _buildChip('Libere', 'Freestyle'),
                    _buildChip('Feminine', 'Women'),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _visibleWrestlers.isEmpty
                    ? const Center(child: Text('Niciun luptător pentru filtrul curent'))
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _visibleWrestlers.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final w = _visibleWrestlers[i];
                    final invited = _alreadyInvited.contains(w.uuid);

                    return Container(
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Stil: ${_roStyle(w.style)}',
                              style:
                              const TextStyle(color: Colors.white)),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed:
                              invited ? null : () => _sendInvite(w),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                invited ? darkGrey : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 14),
                              ),
                              child: Text(
                                invited
                                    ? 'Invitație trimisă'
                                    : 'Trimite invitație',
                                style:
                                const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── helper pentru Chip ───
  Widget _buildChip(String labelRO, String valueEN) {
    final selected = _selectedStyle == valueEN;
    return ChoiceChip(
      checkmarkColor: Colors.white,
      label: Text(
        labelRO,
        style: TextStyle(color: selected ? Colors.white : Colors.black),
      ),
      selected: selected,
      backgroundColor: Colors.white,               // fundal alb când nu e selectat
      selectedColor: primary,                       // fundal roșu când e selectat
      side: BorderSide(color: primary, width: 1.5), // contur roșu
      onSelected: (_) => setState(() => _selectedStyle = valueEN),
    );
  }

  String _roStyle(String en) {
    switch (en) {
      case 'Greco Roman':
        return 'Greco-romane';
      case 'Freestyle':
        return 'Libere';
      case 'Women':
        return 'Feminine';
      default:
        return en;
    }
  }
}
