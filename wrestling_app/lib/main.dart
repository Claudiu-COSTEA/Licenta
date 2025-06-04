import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/views/admin/coaches_invitations_screen.dart';
import 'package:wrestling_app/views/admin/referees_invitations_screen.dart';
import 'package:wrestling_app/views/admin/wrestlers_invitations_screen.dart';
import 'package:wrestling_app/views/admin/wrestling_clubs_invitations_screen.dart';
import 'package:wrestling_app/views/shared/sign_in_screen.dart';
import 'package:wrestling_app/services/notifications_services.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Called when the app is in the background or terminated
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase initialization options
  );

  // Initialize Firebase Messaging
  NotificationsServices().initializeNotifications();

  // Handle background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,          // text & iconiţe AppBar
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      title: 'Wrestling App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/signIn',
      routes: {
        '/signIn': (context) => SignInScreen(),
        '/coaches':    (_) => const CoachesListScreen(),
        '/wrestlers':  (_) => const WrestlersListScreen(),
      },
    );
  }
}


