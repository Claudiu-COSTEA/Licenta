import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_competition_invitation_details.dart';
import 'package:wrestling_app/views/shared/widgets/custom_buttons.dart';

class CompetitionInvitationDetailsScreen extends StatelessWidget {

  final String userType;

  const CompetitionInvitationDetailsScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                Center(
                        child: Text(
                          'FINALA C.N.I. SENIORI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
          
                SizedBox(height: 20),
          
                // Detail Items
                CustomCompetitionInvitationDetails(label: 'Adresa', text: 'Resita, SALA POLIVALENTA REȘIȚA, PIATA 1 DECEMBRIE 1918 NR 5'),
                CustomCompetitionInvitationDetails(label: 'Perioada', text: '23 - 26 Noiembrie 2024'),
                CustomCompetitionInvitationDetails(label: 'Club sportiv', text : 'C.S. Vladimirescu 2013'),
                CustomCompetitionInvitationDetails(label : 'Antrenor', text : 'Ionel Ionut'),
                CustomCompetitionInvitationDetails(label : 'Stil de lupta', text : 'Lupte Greco-Romane'),
                CustomCompetitionInvitationDetails(label : 'Data limita', text: '15 Noiembrie 2024'),
          
                SizedBox(height: 50),
               _buildButtons(userType),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
// Method to build buttons conditionally
  Widget _buildButtons(String userType) {
    List<Widget> buttons = [];

    if (userType == 'coach') {
      buttons.addAll([
        CustomButton(label: 'Selectie luptatori', onPressed: () => {}),
        SizedBox(height: 20,),
        CustomButton(label: 'Luptatori selectati', onPressed: () => {}),
        SizedBox(height: 20,),
        CustomButton(label: 'Trimite raspuns la invitatie', onPressed: () => {}),
      ]);
      return Center(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: buttons));
    } else if (userType == 'wrestler') {
      buttons.addAll([
        CustomButton(label: 'Confirma', onPressed: () => {}),
        CustomButton(label: 'Refuza', onPressed: () => {}),

      ]);
      return Center(child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: buttons));
    }
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: buttons));
  }
}
