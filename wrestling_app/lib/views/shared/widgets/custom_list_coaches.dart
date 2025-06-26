import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wrestling_app/services/constants.dart';
import 'package:wrestling_app/services/notifications_services.dart';
import 'package:wrestling_app/views/shared/widgets/toast_helper.dart';

class CustomCoachesList extends StatefulWidget {
  final List<Map<String, dynamic>> coaches;
  final int userUUID;
  final int competitionUUID;
  final String competitionDeadline;

  const CustomCoachesList({
    super.key,
    required this.coaches,
    required this.userUUID,
    required this.competitionUUID,
    required this.competitionDeadline,
  });

  @override
  State<CustomCoachesList> createState() => _CustomCoachesListState();
}

class _CustomCoachesListState extends State<CustomCoachesList> {
  // Stocăm selecțiile în română
  String selectedStyle = "Toate";       // Default: afișează toate stilurile
  String invitationFilter = "Toate";    // Default: afișează toate invitațiile
  static const Color primary = Color(0xFFB4182D);

  // Listele de opțiuni în română (în UI)
  final List<String> wrestlingStylesRO = [
    "Toate",
    "Greco-romane",
    "Libere",
    "Feminine",
  ];

  final List<String> invitationFiltersRO = [
    "Toate",
    "Invitat",
    "Neinvitat",
  ];

  // Mapări RO → EN pentru filtru stil
  final Map<String, String> roToEnStyle = {
    "Greco-romane": "Greco Roman",
    "Libere": "Freestyle",
    "Feminine": "Women",
  };

  NotificationsServices notificationService = NotificationsServices();

  @override
  Widget build(BuildContext context) {
    // Filtrăm lista pe baza selecțiilor (în română), dar comparăm valorile EN din date
    List<Map<String, dynamic>> filteredCoaches = widget.coaches.where((coach) {
      final enStyle = coach['wrestling_style'] as String? ?? "";
      final hasInvitation = coach['invitation_status'] != null;

      // 1) Stil: dacă e "Toate" sau dacă valoarea EN a coach == roToEnStyle[selectedStyle]
      bool matchesStyle;
      if (selectedStyle == "Toate") {
        matchesStyle = true;
      } else {
        final String? enForSelected = roToEnStyle[selectedStyle];
        matchesStyle = (enStyle == enForSelected);
      }

      // 2) Invitație:
      bool matchesInvitation;
      if (invitationFilter == "Toate") {
        matchesInvitation = true;
      } else if (invitationFilter == "Invitat") {
        matchesInvitation = hasInvitation;
      } else { // "Neinvitat"
        matchesInvitation = !hasInvitation;
      }

      return matchesStyle && matchesInvitation;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 10),

        // *** Filtrul pe stiluri (Buton orizontal) ***
        _buildFilterButtons(
          wrestlingStylesRO,
          selectedStyle,
              (style) {
            setState(() {
              selectedStyle = style;
            });
          },
        ),

        const SizedBox(height: 10),

        // *** Filtrul pe status invitație (Buton orizontal) ***
        _buildFilterButtons(
          invitationFiltersRO,
          invitationFilter,
              (filter) {
            setState(() {
              invitationFilter = filter;
            });
          },
        ),

        const SizedBox(height: 10),

        // *** Lista de antrenori, după aplicarea filtrelor ***
        Expanded(
          child: filteredCoaches.isEmpty
              ? const Center(
            child: Text(
              "Nu există antrenori disponibili.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : ListView.builder(
            itemCount: filteredCoaches.length,
            itemBuilder: (context, index) {
              final coach = filteredCoaches[index];
              final String? invitationStatusEN =
              coach['invitation_status'] as String?;
              final String roStatus = invitationStatusEN != null
                  ? _roStatus(invitationStatusEN)
                  : "Neinvitat";

              final String enStyle =
                  coach['wrestling_style'] as String? ?? "";
              final String roStyle = _roStyle(enStyle);

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4182D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      coach['coach_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "Stil: $roStyle\nStatus: $roStatus",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: ElevatedButton(
                      onPressed: invitationStatusEN == null
                          ? () => _onSelectCoach(
                          context, coach['coach_UUID'] as int)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: invitationStatusEN == null
                            ? Colors.black
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Trimite invitație",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  /// Construieste un rând de butoane de filtrare orizontal
  Widget _buildFilterButtons(
      List<String> optionsRO,
      String selectedRO,
      Function(String) onTap,
      ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        children: optionsRO.map((optionRO) {
          final bool isSelected = optionRO == selectedRO;
          return ElevatedButton(
            onPressed: () => onTap(optionRO),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isSelected ? const Color(0xFFB4182D) : Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFB4182D), width: 2),
              ),
            ),
            child: Text(
              optionRO,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFB4182D),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Traducere “wrestling_style” din EN în RO
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

  /// Traducere “invitation_status” din EN în RO
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

  /// Trimite invitația către antrenor
  void _onSelectCoach(BuildContext context, int coachUUID) async {
    const String _url =
        AppConstants.baseUrl + "wrestlingClub/sendCoachInvitation";

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
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: primary,),
        ),
      );

      final http.Response response = await http.post(
        Uri.parse(_url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "competition_UUID": widget.competitionUUID,
          "recipient_UUID": coachUUID,
          "invitation_deadline": formattedDeadline,
        }),
      );

      Navigator.pop(context); // Închide indicatorul de încărcare

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
        json.decode(response.body);

        if (responseData.containsKey("body") &&
            responseData["body"] is Map<String, dynamic>) {
          final Map<String, dynamic> body =
          responseData["body"] as Map<String, dynamic>;

          if (body.containsKey("message")) {
            
            ToastHelper.succes("Invitație trimisă cu succes !");

            setState(() {
              int index = widget.coaches
                  .indexWhere((c) => c['coach_UUID'] == coachUUID);
              if (index != -1) {
                widget.coaches[index]['invitation_status'] = "Pending";
              }
            });

            String? token =
            await notificationService.getUserFCMToken(coachUUID);
            if (token != null) {
              notificationService.sendFCMMessage(token);
            }
          } else {
            ToastHelper.eroare("Eroare le trimiterea răspunsului");
          }
        } else {
          ToastHelper.eroare("Eroare le trimiterea răspunsului");
        }
      } else {
        ToastHelper.eroare("Eroare le trimiterea răspunsului");
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.eroare("Eroare le trimiterea răspunsului");
      }
    }
  }
}
