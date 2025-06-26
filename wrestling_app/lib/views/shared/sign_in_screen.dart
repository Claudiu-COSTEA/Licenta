import 'package:flutter/material.dart';
import 'package:wrestling_app/services/user_apis_services.dart';
import 'package:wrestling_app/views/shared/widgets/custom_buttons.dart';
import 'package:wrestling_app/views/shared/widgets/custom_label.dart';
import 'package:wrestling_app/services/auth_service.dart';
import 'package:wrestling_app/views/shared/invitations_lists_screen.dart';
import 'package:wrestling_app/services/notifications_services.dart';
import 'package:wrestling_app/views/shared/widgets/toast_helper.dart';

import '../../models/user_model.dart';
import '../admin/admin_actions.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  final UserService _userService = UserService();
 // Create UserService instance
  final NotificationsServices _notificationsServices = NotificationsServices();

  Future<void> _handleSignIn(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    final user = await _authService.signIn(email, password);

    print("!!! 1");
    print(user);
    if (user != null) {
      UserModel? userModel = await _userService.fetchUserByEmail(email);
      print(userModel?.userUUID);

      print("!!! 2");
      print(userModel);

      if(userModel != null) {
        ToastHelper.succes("Autentificare cu succes !");
        _notificationsServices.saveTokenToServer(userModel.userUUID);
        // Navigate to the next screen


        if(userModel.userType == 'Admin') {

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdminActions()),
          );

        } else {


          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InvitationsListsScreen(user: userModel)),
          );
        }
      }
    } else {
      ToastHelper.eroare("Date incorecte !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/wrestling_logo.png',
                    height: 200,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    'Federatia Romana de Lupte',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                CustomLabel(text: 'Email'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                    hintText: 'nume.prenume@frl.ro',
                    hintStyle: const TextStyle(
                      color: Colors.white,          // ←  culoarea hint-ului
                      fontWeight: FontWeight.w400,
                    ),

                    filled: true,
                    fillColor: const Color(0xFFB4182D),   // fundal roşu

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.white), // linie albă
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.white), // linie albă şi la focus
                    ),
                  ),

                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),            // text introdus = alb
                ),


                SizedBox(height: 16),
                CustomLabel(text: 'Parolă'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Parolă',
                    hintStyle: const TextStyle(
                      color: Colors.white,          // ← hint ALB
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Color(0xFFB4182D),   // fundal roșu brand
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),

                    // bordură albă în ambele stări
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  cursorColor: Colors.white,         // cursor alb
                  style: const TextStyle(color: Colors.white), // text introdus = alb
                ),


                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Ai uitat parola ?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: CustomButton(
                    label: 'Autentificare',
                    onPressed: () => _handleSignIn(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
