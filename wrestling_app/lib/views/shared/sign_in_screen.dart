import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_buttons.dart';
import 'package:wrestling_app/views/shared/widgets/custom_text_field.dart';
import 'package:wrestling_app/views/shared/widgets/custom_label.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Wrestling logo
                Center(
                  child: Image.asset(
                    'assets/images/wrestling_logo.png',
                    height: 200,
                  ),
                ),
                SizedBox(height: 10),

                // Federation title
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

                // Email Label and TextField
                CustomLabel(text: 'Email'),
                CustomTextField(obscureText: false, label: ''),
                SizedBox(height: 16),

                // Password Label and TextField
                CustomLabel(text: 'Parola'),
                CustomTextField(obscureText: true, label: ''),
                SizedBox(height: 8),

                // Forgot password text
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

                // Authentication Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(label: 'Autentificare', onPressed: () {}),
                    CustomButton(label: 'Inregistrare', onPressed: () {}),
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
