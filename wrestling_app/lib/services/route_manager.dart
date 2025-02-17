import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RouteManager extends StatelessWidget {
  const RouteManager({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final userRole = snapshot.data;
          if (userRole == 'Wrestling club') {
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/coachDashboard'));
          } else if (userRole == 'wrestler') {
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/wrestlerDashboard'));
          } else {
            Future.microtask(() => Navigator.pushReplacementNamed(context, '/signIn'));
          }
        }
        return SizedBox();
      },
    );
  }

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');  // Return stored user role
  }
}
