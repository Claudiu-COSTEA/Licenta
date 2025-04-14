import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constants.dart';

class NotificationsServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize Firebase Messaging
  Future<void> storeFcmToken(int userUUID, String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse("https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling/storeFcmToken"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_UUID": userUUID,
          "fcm_token": fcmToken,
        }),
      );
      
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData.containsKey("message")) {
          if (kDebugMode) {
            print("FCM token stored successfully: ${responseData["message"]}");
          }
        } else {
          if (kDebugMode) {
            print("Error: ${responseData["error"]}");
          }
        }
      } else {
        if (kDebugMode) {
          print("Failed to store token. Status Code: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("🚨 Error storing FCM token: $e");
      }
    }
  }

  void saveTokenToServer(int userUUID) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      await storeFcmToken(userUUID, token);
    }
  }

  Future<void> initializeNotifications() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print("User granted permission for notifications");
      }
    } else {
      if (kDebugMode) {
        print("User denied notifications permission");
      }
    }

    // Get FCM Token
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }

    // Initialize Local Notifications
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings);

    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Received message: ${message.notification?.title}");
      }

      // Show notification
      _showNotification(
        message.notification?.title ?? "New Notification",
        message.notification?.body ?? "You have a new message.",
      );
    });

    // Handle when user taps on notification (while app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("User tapped on notification: ${message.notification?.title}");
      }
      // Handle navigation or other actions
    });
  }

  // Show Local Notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Send notification functions

  Future<String?> getUserFCMToken(int userUUID) async {
    final String apiUrl = "https://rhybb6zgsb.execute-api.us-east-1.amazonaws.com/wrestling/getUserFcmToken?user_UUID=$userUUID";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        // This is the nested object containing the actual token
        final dynamic rawBody = decodedResponse["body"];

        // In some cases, 'body' might be returned as a string. Let's handle both:
        final body = rawBody is String ? json.decode(rawBody) : rawBody;

        if (body is Map<String, dynamic> && body.containsKey("fcm_token")) {
          return body["fcm_token"];
        } else {
          throw Exception("FCM token not found in response");
        }
      } else if (response.statusCode == 404) {
        throw Exception("User not found");
      } else {
        throw Exception("Failed to fetch FCM token. Status code: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching FCM token: $e");
      }
      return null;
    }
  }


  Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "wrestling-mobile-application",
      "private_key_id": "92ef8d178c8ba89c8dc79cd35a6eb2f469757db5",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDY3jTPzGCRR7bb\nbqJjd/KGg3uwieLmdEDuvNywje+G6K1RUd41axq+piCPDiP2LexqMZsO6ozTi3VW\nzwq69r3itNn8z8mgoOV0QCCwaJUyws9LBVk+2sKrjbn+aYQMOZPmSuqTy4VFzPHU\nCSUMJDJrJkp6NMQTz0mJKV4rtXq4Q/d9z5WavLbGVXVCgKW3nrow72MNCFFlbqme\nPZq0DtxalKp4GMoRtzPbTe9rHB2fEsj7xMwbNIR2DxSQc1oKIIYL7V+gh32n5fIk\nBM3oag3Xj9JnGRLOqVzVEu1ZGcC7PMFtq9ZcejZq756/NNfpJ1xbPrxnbjDyX+i4\nY3eNQ7EpAgMBAAECggEAAzYmylyoELSR899us23TYmyq30Q3eMN/mLucW8ZfpeA4\nHxvRgnFNyE3iEGIi+W4g1g5aXqsyB5av2/jBpBK4gureI3lXQ/69cUW4+WeJvnwU\nBXyJ8MgQDpSu7sA25sXHCuey4BpTz2dCaIfz7/Joi5leDFlYUwAK7QVQl2klV5x+\n8ZZham71avyrfvnnfbG5KUILBJXyRpY5VI6beiOULcMb1GJ6uHpwiJRSgj703lGx\n1iZZ66nfUPWhz/9HDmZ9G9iaxYD38TXyQRmXfg9nidd8i/oO+G0yHsPrfk/fT0kJ\nG6bMtfemRjt1gJuk2ejNIk9UErbWRa9+szRSch3BxQKBgQDudtife6+EnNhiIubd\n5nCeI0JnuE6jQHKcK5drNnz/+4gKtbpocd9f6ceBLj3F3en5Rw115zCPAEQkSQUv\nwXIbWgNTGm7hUcv4DVA9bMWnBaSWD1AXJN1J5JmB5sARaOim3loHN4YF3EvqEF2v\nQIBjzSoUWEzyTOC1g5OEuYhxnQKBgQDo0M4Me0QVTBYNYgdKtUOsA8Gvki1cbSdw\neGlbuhVC1V2LUpqeKeEZ2ADPBqQG1YvBzCtOKbHisnq+nGMBqebtuK92uz7VQY+H\nkiUtXSVgM0Ab51OmwMSTJS8YBe8PeaDOttKSsyLAvhWMFm06WluvsUPoZ7HZ0g/X\ncV6jgO09/QKBgBM4HOltrI3Bnmb6bSUBR55XNSjq39ukfBg+IywO7jArc6F5WBbG\n5rvyOZQdx/jEk/D1Ww5fnbhIyzUpdXON4cZ2kMIH5VvfndLWL9tjguKdP9CgV1Im\nNHeaJw0jLeO5UtbwIM1oGjMquCubOhG/3xksFfIh08HLlGjMu/z8fxS5AoGATJ9U\nARWcjanR5CusHLFViUpfN2pTlYSzIzft7OtsTees9sqD6qP72qaVdY1I9JrZeTm5\n0uq0CdkVvp/3kbeaMgjDbr8nacY+965on+p0/5k+czCJ/mqZB5iITE6/pAcynnXb\nDb75JBgrPUSwRDEy1brwj495ICgbYJuGOyeWbP0CgYBI2/CPb/M4/FrWtZ6Vk9yQ\nonPl7bRh1UwSzNeQPUcmt5TsLomGBeqfwC54ZL8oO1nJFXAE0Iq1KzRpEV83DCPM\nJ/66qKlRNoAtFEQsjkrCAcApkgYFT32z4qZc5YFRnQ9dtDinb9YZEMLnhhbRbVPa\nIdgHVZi3ktP5tdQljfj/qA==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@wrestling-mobile-application.iam.gserviceaccount.com",
      "client_id": "103630795752692587313",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40wrestling-mobile-application.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;

  }

  Future<void> sendFCMMessage(String token) async {
    final String serverKey = await getAccessToken() ; // Your FCM server key
    final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/wrestling-mobile-application/messages:send';
    final  currentFCMToken = token;
    if (kDebugMode) {
      print("fcmkey : $currentFCMToken");
    }
    final Map<String, dynamic> message = {
      'message': {
        'token': currentFCMToken, // Token of the device you want to send the message to
        'notification': {
          'body': "Invitatie pentru competitie primita !",
          'title': 'Invitatie competitie'
        },
        'data': {
          'current_user_fcm_token': currentFCMToken, // Include the current user's FCM token in data payload
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('FCM message sent successfully');
      }
    } else {
      if (kDebugMode) {
        print('Failed to send FCM message: ${response.statusCode}');
      }
    }
  }


}
