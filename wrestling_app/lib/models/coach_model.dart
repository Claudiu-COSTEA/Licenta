class Coach {
  final int coachUUID;
  final String coachName;
  final String wrestlingStyle;
  late final String? invitationStatus; // Nullable if no invitation was sent

  Coach({
    required this.coachUUID,
    required this.coachName,
    required this.wrestlingStyle,
    this.invitationStatus,
  });

  // Factory method to create a Coach object from JSON
  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      coachUUID: json['coach_UUID'],
      coachName: json['coach_name'],
      wrestlingStyle: json['wrestling_style'],
      invitationStatus: json['invitation_status'], // Can be null if no invitation exists
    );
  }

  // Convert Coach object to JSON
  Map<String, dynamic> toJson() {
    return {
      "coach_UUID": coachUUID,
      "coach_name": coachName,
      "wrestling_style": wrestlingStyle,
      "invitation_status": invitationStatus,
    };
  }
}
