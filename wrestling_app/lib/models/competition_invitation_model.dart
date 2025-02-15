class CompetitionInvitation {
  final String invitationUUID;
  final String eventUUID;
  final String? wrestlingClubUUID;
  final String? coachUUID;
  final String? wrestlerUUID;
  final String? weightCategory;
  final String? wrestlingStyle;
  final String registrationStatus;
  final DateTime invitationDate;
  final DateTime invitationDeadline;
  final DateTime? invitationResponseDate;

  CompetitionInvitation({
    required this.invitationUUID,
    required this.eventUUID,
    this.wrestlingClubUUID,
    this.coachUUID,
    this.wrestlerUUID,
    this.weightCategory,
    this.wrestlingStyle,
    required this.registrationStatus,
    required this.invitationDate,
    required this.invitationDeadline,
    this.invitationResponseDate,
  });

  factory CompetitionInvitation.fromJson(Map<String, dynamic> json) {
    return CompetitionInvitation(
      invitationUUID: json['event_invitation_UUID'],
      eventUUID: json['event_UUID'],
      wrestlingClubUUID: json['wrestling_club_UUID'],
      coachUUID: json['coach_UUID'],
      wrestlerUUID: json['wrestler_UUID'],
      weightCategory: json['weight_category'],
      wrestlingStyle: json['wrestling_style'],
      registrationStatus: json['registration_status'],
      invitationDate: DateTime.parse(json['invitation_date']),
      invitationDeadline: DateTime.parse(json['invitation_deadline']),
      invitationResponseDate: json['invitation_response_date'] != null
          ? DateTime.parse(json['invitation_response_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_invitation_UUID': invitationUUID,
      'event_UUID': eventUUID,
      'wrestling_club_UUID': wrestlingClubUUID,
      'coach_UUID': coachUUID,
      'wrestler_UUID': wrestlerUUID,
      'weight_category': weightCategory,
      'wrestling_style': wrestlingStyle,
      'registration_status': registrationStatus,
      'invitation_date': invitationDate.toIso8601String(),
      'invitation_deadline': invitationDeadline.toIso8601String(),
      'invitation_response_date': invitationResponseDate?.toIso8601String(),
    };
  }
}
