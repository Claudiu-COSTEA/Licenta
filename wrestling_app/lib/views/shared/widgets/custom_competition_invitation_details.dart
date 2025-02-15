import 'package:flutter/material.dart';

class CustomCompetitionInvitationDetails extends StatelessWidget {
  final String label;
  final String text;

  const CustomCompetitionInvitationDetails({super.key, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildDetailItem(label, text),
    );
  }

  // Custom Detail Item Widget
  Widget _buildDetailItem(String title, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFB4182D), width: 5),
        borderRadius: BorderRadius.circular(50),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(text: '$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
