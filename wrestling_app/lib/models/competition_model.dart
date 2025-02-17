class Competition {
  final int competitionUUID;
  final String competitionName;
  final DateTime competitionStartDate;
  final DateTime competitionEndDate;
  final String competitionLocation;

  Competition({
    required this.competitionUUID,
    required this.competitionName,
    required this.competitionStartDate,
    required this.competitionEndDate,
    required this.competitionLocation,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      competitionUUID: json['competition_UUID'],
      competitionName: json['competition_name'],
      competitionStartDate: DateTime.parse(json['competition_start_date']),
      competitionEndDate: DateTime.parse(json['competition_end_date']),
      competitionLocation: json['competition_location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competition_UUID': competitionUUID,
      'competition_name': competitionName,
      'competition_start_date': competitionStartDate.toIso8601String(),
      'competition_end_date': competitionEndDate.toIso8601String(),
      'competition_location': competitionLocation,
    };
  }
}
