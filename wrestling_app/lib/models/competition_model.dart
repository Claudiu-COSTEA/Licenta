class Competition {
  final String eventUUID;
  final String eventName;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final String eventLocation;

  Competition({
    required this.eventUUID,
    required this.eventName,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.eventLocation,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      eventUUID: json['event_UUID'],
      eventName: json['event_name'],
      eventStartDate: DateTime.parse(json['event_start_date']),
      eventEndDate: DateTime.parse(json['event_end_date']),
      eventLocation: json['event_location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_UUID': eventUUID,
      'event_name': eventName,
      'event_start_date': eventStartDate.toIso8601String(),
      'event_end_date': eventEndDate.toIso8601String(),
      'event_location': eventLocation,
    };
  }
}
