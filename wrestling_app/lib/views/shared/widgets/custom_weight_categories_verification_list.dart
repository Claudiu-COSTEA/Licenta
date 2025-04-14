import 'package:flutter/material.dart';
import 'package:wrestling_app/views/referee/referee_wrestlers_verification.dart';
import '../../../models/wrestler_weight_category_model.dart';

class CustomWeightCategoriesVerificationList extends StatefulWidget {
  final List<WrestlerWeightCategory> items; // List of competition invitations
  final VoidCallback onRefresh; // ✅ Callback to refresh the parent screen
  final int competitionUUID;

  const CustomWeightCategoriesVerificationList({
    super.key,
    required this.items,
    required this.onRefresh, required this.competitionUUID, // ✅ Receive callback
  });

  @override
  State<CustomWeightCategoriesVerificationList> createState() =>
      _CustomWeightCategoriesVerificationListState();
}

class _CustomWeightCategoriesVerificationListState
    extends State<CustomWeightCategoriesVerificationList> {
  String selectedStyle = "All"; // ✅ Default: Show all styles

  final List<String> wrestlingStyles = [
    "All",
    "Greco Roman",
    "Freestyle",
    "Women"
  ]; // ✅ Wrestling styles

  @override
  Widget build(BuildContext context) {
    // **Filter items based on selected wrestling style**
    List<WrestlerWeightCategory> filteredItems = widget.items.where((item) {
      return selectedStyle == "All" || item.wrestlingStyle == selectedStyle;
    }).toList();

    return Column(
      children: [
        const SizedBox(height: 10),

        // **Wrestling Style Filter Buttons**
        _buildFilterButtons(),

        const SizedBox(height: 10),

        // **Filtered ListView**
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
              final wrestlingStyle = item.wrestlingStyle ?? 'Unknown';

              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFB4182D), // Red background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      "$weightCategory",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Stil de luptă: $wrestlingStyle',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RefereeWrestlersVerification(wrestlerStyle: wrestlingStyle, wrestlerWeightCategory: weightCategory, competitionUUID: widget.competitionUUID,)),
                        );
                      // Handle tap action if needed
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

  // **Builds Filter Buttons for Wrestling Styles**
  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        children: wrestlingStyles.map((style) {
          return ElevatedButton(
            onPressed: () {
              setState(() {
                selectedStyle = style;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedStyle == style
                  ? const Color(0xFFB4182D) // Selected: Red
                  : Colors.white, // Default: White
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFB4182D), width: 2),
              ),
            ),
            child: Text(
              style,
              style: TextStyle(
                color: selectedStyle == style
                    ? Colors.white
                    : const Color(0xFFB4182D), // Text color
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
