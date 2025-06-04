// file: lib/screens/referees_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrestling_app/models/referee_complete_model.dart';
import '../../services/admin_apis_services.dart';
import '../shared/widgets/toast_helper.dart';

class RefereesListScreen extends StatefulWidget {
  final int competitionUUID;
  const RefereesListScreen({Key? key, required this.competitionUUID})
      : super(key: key);

  @override
  State<RefereesListScreen> createState() => _RefereesListScreenState();
}

class _RefereesListScreenState extends State<RefereesListScreen> {
  final _svc = AdminServices();

  late Future<void> _loader;
  List<RefereeCompleteModel> _allRefs = [];
  final Set<int> _alreadyInvited = {};

  // ─── filtrare după stil ───
  String _selectedStyle = 'Toți';           // Toți | Greco Roman | Freestyle | Women
  List<RefereeCompleteModel> get _visibleRefs {
    if (_selectedStyle == 'Toți') return _allRefs;
    return _allRefs
        .where((r) => r.wrestlingStyle == _selectedStyle)
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
    _allRefs = await _svc.fetchReferees();
    final invites = await _svc.fetchInvitationsByRole(
      role: 'Referee',
      competitionUUID: widget.competitionUUID.toString(),
    );
    _alreadyInvited
      ..clear()
      ..addAll(invites.map((e) => e.recipientUUID));
  }

  Future<void> _sendInvite(RefereeCompleteModel ref) async {
    if (_alreadyInvited.contains(ref.uuid)) return;

    final deadline = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.now().add(const Duration(hours: 72)));

    final res = await _svc.sendInvitation(
      competitionUUID: widget.competitionUUID,
      recipientUUID: ref.uuid,
      recipientRole: 'Referee',
      status: 'Pending',
      deadline: deadline,
    );

    if (!mounted) return;
    if (res.success) {
      setState(() => _alreadyInvited.add(ref.uuid));
      ToastHelper.succes('Invitație trimisă!');
    } else {
      ToastHelper.eroare('Eroare la trimitere: ${res.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arbitri'), backgroundColor: primary),
      body: FutureBuilder<void>(
        future: _loader,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                child: _visibleRefs.isEmpty
                    ? const Center(child: Text('Niciun arbitru pentru filtrul curent'))
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _visibleRefs.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = _visibleRefs[i];
                    final invited = _alreadyInvited.contains(r.uuid);

                    return Container(
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.fullName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Stil: ${_roStyle(r.wrestlingStyle)}',
                              style:
                              const TextStyle(color: Colors.white)),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed:
                              invited ? null : () => _sendInvite(r),
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
      label: Text(labelRO,
          style: TextStyle(color: selected ? Colors.white : Colors.black)),
      selected: selected,
      selectedColor: primary,
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
