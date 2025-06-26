import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';
import 'package:wrestling_app/services/notifications_services.dart';
import 'package:wrestling_app/views/shared/widgets/toast_helper.dart';

class CustomWrestlersList extends StatefulWidget {
  final List<Map<String, dynamic>> wrestlers;
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;

  const CustomWrestlersList({
    super.key,
    required this.wrestlers,
    required this.userUUID,
    required this.competitionUUID,
    required this.competitionDeadline,
  });

  @override
  State<CustomWrestlersList> createState() => _CustomWrestlersListState();
}

class _CustomWrestlersListState extends State<CustomWrestlersList> {
  static const Color primary = Color(0xFFB4182D);

  String selectedInvitationFilter = "Toate";
  final List<String> invitationFiltersRO = ["Toate", "Invitat", "Neinvitat"];

  final NotificationsServices notificationService = NotificationsServices();

  // Controller pentru fiecare wrestler (pentru câmpul "Kg")
  final Map<int, TextEditingController> _controllers = {};
  // Flag pentru a preveni invitații multiple simultan
  final Map<int, bool> _isSending = {};

  @override
  void initState() {
    super.initState();
    for (var w in widget.wrestlers) {
      final int id = w['wrestler_UUID'] as int;
      _controllers[id] = TextEditingController();
      _isSending[id] = false;
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredWrestlers = widget.wrestlers.where((w) {
      final String? enStatus = w['invitation_status'] as String?;
      if (selectedInvitationFilter == "Toate") return true;
      if (selectedInvitationFilter == "Invitat") {
        // „Invitat” = orice status diferit de null
        return enStatus != null;
      }
      // „Neinvitat” = status == null
      return enStatus == null;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 10),

        // Butoane de filtrare după invitation_status
        _buildFilterButtons(),

        const SizedBox(height: 10),

        // Lista lupători
        Expanded(
          child: filteredWrestlers.isEmpty
              ? const Center(
            child: Text(
              "Nu există luptători disponibili.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredWrestlers.length,
            itemBuilder: (context, index) {
              final wrestler = filteredWrestlers[index];
              final int id = wrestler['wrestler_UUID'] as int;
              final String name =
                  wrestler['wrestler_name'] ?? "Nume necunoscut";
              final String? enStatus =
              wrestler['invitation_status'] as String?;
              final String roStatus = enStatus != null
                  ? _roStatus(enStatus)
                  : "Neinvitat";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nume luptător
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Dacă invitation_status != null => afișăm categoria și status
                        if (enStatus != null) ...[
                          Text(
                            "Categorie: ${wrestler['weight_category'] ?? ''} Kg",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Status: $roStatus",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                        ] else ...[
                          // Dacă invitation_status == null => afișăm câmpul "Kg" + status "Neinvitat"
                          Text(
                            "Status: Neinvitat",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 28,
                                child: TextField(
                                  controller: _controllers[id],
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: "Kg",
                                    hintStyle: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) {
                                    _submitInvitation(id);
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Kg",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Buton „Trimite invitație”
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: enStatus == null
                                ? () => _submitInvitation(id)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: enStatus == null
                                  ? Colors.black
                                  : Colors.grey,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Trimite invitație",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: invitationFiltersRO.map((optionRO) {
          final bool isSelected = optionRO == selectedInvitationFilter;
          return ElevatedButton(
            onPressed: () {
              setState(() {
                selectedInvitationFilter = optionRO;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? primary : Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: primary, width: 2),
              ),
            ),
            child: Text(
              optionRO,
              style: TextStyle(
                color: isSelected ? Colors.white : primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _roStatus(String statusEN) {
    switch (statusEN.toLowerCase()) {
      case 'accepted':
        return 'Acceptat';
      case 'declined':
        return 'Refuzat';
      case 'confirmed':
        return 'Confirmat';
      case 'pending':
        return 'În așteptare';
      default:
        return statusEN;
    }
  }

  void _submitInvitation(int id) {
    final String enteredCategory = _controllers[id]?.text.trim() ?? "";
    if (enteredCategory.isEmpty) {
      ToastHelper.eroare("Introduceți categoria !");
      return;
    }
    _onSelectWrestler(context, id, enteredCategory);
  }

  void _onSelectWrestler(
      BuildContext context, int wrestlerUUID, String weightCategory) async {
    const String _url =
        AppConstants.baseUrl + "coach/sendWrestlerInvitation";

    try {
      DateTime competitionDeadline =
      DateTime.parse(widget.competitionDeadline);
      DateTime newDeadline =
      competitionDeadline.subtract(const Duration(days: 7));
      String formattedDeadline =
      DateFormat("yyyy-MM-dd HH:mm:ss").format(newDeadline);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
        const Center(child: CircularProgressIndicator(color: primary)),
      );

      final response = await http.post(
        Uri.parse(_url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": widget.competitionUUID,
          "recipient_UUID": wrestlerUUID,
          "invitation_deadline": formattedDeadline,
          "weight_category": weightCategory,
        }),
      );

      Navigator.pop(context); // Închide indicatorul

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData =
        json.decode(response.body) as Map<String, dynamic>;

        if (responseData.containsKey("body") &&
            responseData["body"] is Map<String, dynamic>) {
          final body = responseData["body"] as Map<String, dynamic>;

          if (body.containsKey("success")) {
            ToastHelper.succes('Invitația a fost trimisă cu succes !');

            setState(() {
              int index = widget.wrestlers
                  .indexWhere((c) => c['wrestler_UUID'] == wrestlerUUID);
              if (index != -1) {
                widget.wrestlers[index]['invitation_status'] = "Pending";
                widget.wrestlers[index]['weight_category'] = weightCategory;
                _controllers[wrestlerUUID]?.text = weightCategory;
              }
            });

            final token =
            await notificationService.getUserFCMToken(wrestlerUUID);
            if (token != null) {
              notificationService.sendFCMMessage(token);
            }
          } else {
            ToastHelper.eroare("Eroare la trimiterea invitației.");
          }
        } else {
          ToastHelper.eroare("Răspuns neașteptat de la server.");
        }
      } else {
        ToastHelper.eroare("Eroare la trimiterea invitației.");
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.eroare("Eroare la trimiterea invitației.");
      }
    }
  }
}
