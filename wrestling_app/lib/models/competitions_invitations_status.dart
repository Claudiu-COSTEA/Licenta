// file: lib/models/club_invitation.dart

import 'package:intl/intl.dart';

class ClubInvitation {
  final String clubName;
  final String city;
  final String invitationStatus;
  final DateTime invitationDeadline;

  ClubInvitation({
    required this.clubName,
    required this.city,
    required this.invitationStatus,
    required this.invitationDeadline,
  });

  /// Constructs from a JSON map (decoded from the inner `body` array).
  factory ClubInvitation.fromJson(Map<String, dynamic> json) {
    // The API returns invitation_deadline as a string "yyyy-MM-dd HH:mm:ss"
    final rawDate = json['invitation_deadline'] as String;
    final parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(rawDate);

    return ClubInvitation(
      clubName: json['club_name'] as String,
      city: json['city'] as String,
      invitationStatus: json['invitation_status'] as String,
      invitationDeadline: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'club_name': invitationDeadline.toIso8601String(),
    'city': city,
    'invitation_status': invitationStatus,
    'invitation_deadline':
    DateFormat('yyyy-MM-dd HH:mm:ss').format(invitationDeadline),
  };
}
