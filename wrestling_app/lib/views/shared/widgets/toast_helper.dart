import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  /// Afișează un mesaj verde de succes, sus pe ecran.
  static void succes(String text) {
    Fluttertoast.cancel();            // oprește eventualul toast deschis
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFF4CAF50), // verde
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  /// Afișează un mesaj roșu de eroare, jos pe ecran.
  static void eroare(String text) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFFF44336), // roșu
      textColor: Colors.white,
      fontSize: 16,
    );
  }
}
