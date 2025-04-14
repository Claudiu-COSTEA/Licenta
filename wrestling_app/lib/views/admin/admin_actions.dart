import 'package:flutter/material.dart';
import 'package:wrestling_app/views/admin/send_invitation_screen.dart';
import 'package:wrestling_app/views/admin/prediction_screen.dart';
import '../../services/auth_service.dart';
import 'add_competition_screen.dart';

class AdminActions extends StatelessWidget {

  final AuthService _authService = AuthService();

   AdminActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [

                  const SizedBox(width: 275),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () => _authService.signOut(context),
                    ),
                  ),


              const SizedBox(height: 200),
          
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddCompetitionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4182D),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                ),
                child: const Text(
                  "Adauga competitie",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendInvitationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4182D),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                ),
                child: const Text(
                  "Trimite invitatie club de lupte",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PredictionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4182D),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                ),
                child: const Text(
                  "Predictie",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
