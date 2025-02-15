import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_buttons.dart';

class WrestlerSelectionDetailsScreen extends StatefulWidget {
  const WrestlerSelectionDetailsScreen({super.key});

  @override
  State<WrestlerSelectionDetailsScreen> createState() => _WrestlerSelectionDetailsScreen();
}

class _WrestlerSelectionDetailsScreen extends State<WrestlerSelectionDetailsScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 200),  // Top spacing
            Center(
              child: Text(
                'Nume complet luptator',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 100),  // Top spacing

            CustomDropdown(),

            SizedBox(height: 100),  // Top spacing

            Center(child: CustomButton(label: 'Trimite invitatie', onPressed:() => {})),

          ],
        ),
      ),
    );
  }
}
