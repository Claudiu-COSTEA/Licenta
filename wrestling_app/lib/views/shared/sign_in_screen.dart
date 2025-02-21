import 'package:flutter/material.dart';
import 'package:wrestling_app/services/user_apis_services.dart';
import 'package:wrestling_app/views/shared/widgets/custom_buttons.dart';
import 'package:wrestling_app/views/shared/widgets/custom_text_field.dart';
import 'package:wrestling_app/views/shared/widgets/custom_label.dart';
import 'package:wrestling_app/services/auth_service.dart';
import 'package:wrestling_app/views/shared/invitations_lists_screen.dart';

import '../../models/user_model.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService(); // Create UserService instance

  Future<void> _handleSignIn(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    final user = await _authService.signIn(email, password);
    if (user != null) {
      UserModel? userModel = await _userService.fetchUserByEmail(email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed in!')),
      );

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvitationsListsScreen(user: userModel)), // Replace HomePage with your destination
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in')),
      );
    }
  }

  Future<void> _handleSignUp(BuildContext context) async {
    final user = await _authService.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed up!')),
      );
      // Navigate to the next screen (replace with your navigation logic)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up')),
      );
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
                CustomTextField(
                  controller: _emailController,
                  obscureText: false,
                  label: '',
                ),
                SizedBox(height: 16),
                CustomLabel(text: 'Parola'),
                CustomTextField(
                  controller: _passwordController,
                  obscureText: true,
                  label: '',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      label: 'Autentificare',
                      onPressed: () => _handleSignIn(context),
                    ),
                    CustomButton(
                      label: 'Inregistrare',
                      onPressed: () => _handleSignUp(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
