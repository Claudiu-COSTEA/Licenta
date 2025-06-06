import 'package:flutter/material.dart';

class CustomListCoachesRespond extends StatefulWidget {
  final List<Map<String, dynamic>> coaches;
  final int userUUID;
  final int competitionUUID;

  const CustomListCoachesRespond({
    super.key,
    required this.coaches,
    required this.userUUID,
    required this.competitionUUID,
  });

  @override
  State<CustomListCoachesRespond> createState() =>
      _CustomListCoachesRespondState();
}

class _CustomListCoachesRespondState extends State<CustomListCoachesRespond> {
  // Selectări în română
  String selectedStyle = "Toate";          // Default: afișează toate stilurile
  String selectedInvitationStatus = "Toate"; // Default: afișează toate statusurile

  // Liste de opțiuni în română
  final List<String> wrestlingStylesRO = [
    "Toate",
    "Greco-romane",
    "Libere",
    "Feminine",
  ];

  final List<String> invitationStatusesRO = [
    "Toate",
    "Acceptat",
    "Refuzat",
  ];

  // Mapări RO → EN pentru filtrele de stil
  final Map<String, String> roToEnStyle = {
    "Greco-romane": "Greco Roman",
    "Libere": "Freestyle",
    "Feminine": "Women",
  };

  // Mapări RO → EN pentru filtrele de status invitație
  final Map<String, String> roToEnStatus = {
    "Acceptat": "Accepted",
    "Refuzat": "Declined",
  };

  @override
  Widget build(BuildContext context) {
    // Filtrăm lista pe baza selecțiilor (în română), dar comparăm valorile EN din date
    List<Map<String, dynamic>> filteredCoaches = widget.coaches.where((coach) {
      final String enStyle = coach['wrestling_style'] as String? ?? "";
      final String? invitationStatusEN =
      coach['invitation_status'] as String?;

      // 1) Filtru Stil
      bool matchesStyle;
      if (selectedStyle == "Toate") {
        matchesStyle = true;
      } else {
        final String? enForSelected = roToEnStyle[selectedStyle];
        matchesStyle = enStyle == enForSelected;
      }

      // 2) Filtru Status invitație
      bool matchesStatus;
      if (selectedInvitationStatus == "Toate") {
        // includem atât cei cu invitation_status != null
        // cât și cei cu invitation_status == null
        matchesStatus = true;
      } else {
        // dacă s-a selectat „Acceptat” sau „Refuzat”, includem doar cei care au acel EN
        final String? enForSelectedStatus =
        roToEnStatus[selectedInvitationStatus];
        matchesStatus =
        (invitationStatusEN != null && invitationStatusEN == enForSelectedStatus);
      }

      return matchesStyle && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),

          // *** Filtrul pe Stiluri (buton orizontal) ***
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

          // *** Filtrul pe Status invitație (buton orizontal) ***
          _buildFilterButtons(
            invitationStatusesRO,
            selectedInvitationStatus,
                (status) {
              setState(() {
                selectedInvitationStatus = status;
              });
            },
          ),

          const SizedBox(height: 10),

          // *** Lista de antrenori, după filtrare ***
          Expanded(
            child: filteredCoaches.isEmpty
                ? const Center(
              child: Text(
                "Nu există antrenori disponibili.",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              itemCount: filteredCoaches.length,
              itemBuilder: (context, index) {
                final coach = filteredCoaches[index];
                final String enStyle =
                    coach['wrestling_style'] as String? ?? "";
                final String roStyle = _roStyle(enStyle);

                final String? invitationStatusEN =
                coach['invitation_status'] as String?;
                final String roStatus = invitationStatusEN != null
                    ? _roStatus(invitationStatusEN)
                    : "Neinvitat";

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
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        "Stil: $roStyle\nStatus: $roStatus",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
}
