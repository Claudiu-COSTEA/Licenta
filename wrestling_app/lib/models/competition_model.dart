class Competition {
  final int competitionUUID;
  final String competitionName;
  final DateTime competitionStartDate;
  final DateTime competitionEndDate;
  final String competitionLocation;
  final String competitionStatus;
  final String? competitionResults;

  Competition({
    required this.competitionUUID,
    required this.competitionName,
    required this.competitionStartDate,
    required this.competitionEndDate,
    required this.competitionLocation,
    required this.competitionStatus,
    this.competitionResults,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      competitionUUID: json['competition_UUID'] as int,
      competitionName: json['competition_name'] as String,
      competitionStartDate: DateTime.parse(json['competition_start_date'] as String),
      competitionEndDate: DateTime.parse(json['competition_end_date'] as String),
      competitionLocation: json['competition_location'] as String,
      competitionStatus: json['competition_status'] as String,
      competitionResults: json['competition_results'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'competition_UUID': competitionUUID,
    'competition_name': competitionName,
    'competition_start_date': competitionStartDate.toIso8601String(),
    'competition_end_date': competitionEndDate.toIso8601String(),
    'competition_location': competitionLocation,
    'competition_status': competitionStatus,
    if (competitionResults != null) 'competition_results': competitionResults,
  };
}
