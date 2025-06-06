import 'package:flutter/material.dart';
import 'package:wrestling_app/views/referee/referee_wrestlers_verification.dart';
import '../../../models/wrestler_weight_category_model.dart';

class CustomWeightCategoriesVerificationList extends StatefulWidget {
  final List<WrestlerWeightCategory> items;
  final VoidCallback onRefresh;
  final int competitionUUID;

  const CustomWeightCategoriesVerificationList({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.competitionUUID,
  });

  @override
  State<CustomWeightCategoriesVerificationList> createState() =>
      _CustomWeightCategoriesVerificationListState();
}

class _CustomWeightCategoriesVerificationListState
    extends State<CustomWeightCategoriesVerificationList> {
  String selectedStyle = "Toate"; // Default: afișează toate stilurile

  // Opțiuni în română
  final List<String> wrestlingStylesRO = [
    "Toate",
    "Greco-romane",
    "Libere",
    "Feminine",
  ];

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

  // Mapare RO → EN pentru comparare
  final Map<String, String> roToEnStyle = {
    "Greco-romane": "Greco Roman",
    "Libere": "Freestyle",
    "Feminine": "Women",
  };

  @override
  Widget build(BuildContext context) {
    // Filtrăm elementele pe baza stilului selectat în română
    List<WrestlerWeightCategory> filteredItems = widget.items.where((item) {
      if (selectedStyle == "Toate") return true;
      final String? enForSelected = roToEnStyle[selectedStyle];
      return item.wrestlingStyle == enForSelected;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 20),

        // Butoane de filtrare în română
        _buildFilterButtons(),

        const SizedBox(height: 30),

        // Lista filtrată
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(
            child: Text(
              "Nu există categorii pentru acest stil de luptă.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
              : ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final weightCategory = item.weightCategory ?? 'Unknown';
              final wrestlingStyleEN = item.wrestlingStyle ?? 'Unknown';
              final wrestlingStyleRO = _roStyle(wrestlingStyleEN);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4182D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      '$weightCategory Kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Stil de luptă: $wrestlingStyleRO',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RefereeWrestlersVerification(
                            wrestlerStyle: wrestlingStyleEN,
                            wrestlerWeightCategory: weightCategory,
                            competitionUUID: widget.competitionUUID,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Construiește butoanele de filtrare (în română)
  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        children: wrestlingStylesRO.map((styleRO) {
          final bool isSelected = styleRO == selectedStyle;
          return ElevatedButton(
            onPressed: () {
              setState(() {
                selectedStyle = styleRO;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isSelected ? const Color(0xFFB4182D) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFB4182D), width: 2),
              ),
            ),
            child: Text(
              styleRO,
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
}
