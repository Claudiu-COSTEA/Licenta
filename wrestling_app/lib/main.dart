import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/sign_in_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase initialization options
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wrestling App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/signIn',
      routes: {
        '/signIn': (context) => SignInScreen(),
      },
    );
  }
}
