class CompetitionInvitation {
  final int invitationUUID;
  final int competitionUUID;
  final int recipientUUID;
  final String recipientRole;
  final String competitionName;
  final String? weightCategory; // ✅ Allow null
  final DateTime competitionStartDate;
  final DateTime competitionEndDate;
  final String competitionLocation;
  final String invitationStatus;
  final DateTime invitationDate;
  final DateTime invitationDeadline;
  final DateTime? invitationResponseDate; // ✅ Allow null

  CompetitionInvitation({
    required this.invitationUUID,
    required this.competitionUUID,
    required this.recipientUUID,
    required this.recipientRole,
    required this.competitionName,
    this.weightCategory, // ✅ Nullable
    required this.competitionStartDate,
    required this.competitionEndDate,
    required this.competitionLocation,
    required this.invitationStatus,
    required this.invitationDate,
    required this.invitationDeadline,
    this.invitationResponseDate, // ✅ Nullable
  });

  factory CompetitionInvitation.fromJson(Map<String, dynamic> json) {
    return CompetitionInvitation(
      invitationUUID: json['invitationUUID'] ?? 0, // ✅ Default value if null
      competitionUUID: json['competition_UUID'] ?? 0, // ✅ Default value
      recipientUUID: json['recipient_UUID'] ?? 0, // ✅ Default value
      recipientRole: json['recipient_role'] ?? "Unknown",
      competitionName: json['competition_name'] ?? "Unknown",
      weightCategory: json['weight_category'], // ✅ Nullable
      competitionStartDate: DateTime.tryParse(json['competition_start_date'] ?? "") ?? DateTime(2000),
      competitionEndDate: DateTime.tryParse(json['competition_end_date'] ?? "") ?? DateTime(2000),
      competitionLocation: json['competition_location'] ?? "Unknown",
      invitationStatus: json['invitation_status'] ?? "Unknown",
      invitationDate: DateTime.tryParse(json['invitation_date'] ?? "") ?? DateTime(2000),
      invitationDeadline: DateTime.tryParse(json['invitation_deadline'] ?? "") ?? DateTime(2000),
      invitationResponseDate: json['invitation_response_date'] != null
          ? DateTime.tryParse(json['invitation_response_date'])
          : null, // ✅ Allow null
    );
  }
}