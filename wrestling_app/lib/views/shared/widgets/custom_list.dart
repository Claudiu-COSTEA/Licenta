import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomList extends StatelessWidget {
  final List<String> items;

  const CustomList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFB4182D), // Red background
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                items[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,  // White text for contrast
                ),
              ),
              onTap: () {
                if (kDebugMode) {
                  print('Tapped on ${items[index]}');
                }
              },
            ),
          ),
        );
      },
    );
  }
}
