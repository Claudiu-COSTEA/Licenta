// file: lib/models/coach_complete_model.dart

class CoachCompleteModel {
  final int coachUuid;
  final String coachName;
  final String wrestlingStyle;
  final int clubUuid;
  final String clubName;
  final String clubCity;

  CoachCompleteModel({
    required this.coachUuid,
    required this.coachName,
    required this.wrestlingStyle,
    required this.clubUuid,
    required this.clubName,
    required this.clubCity,
  });

  /// Creează o instanță dintr-un JSON map (decodificat din răspunsul Lambda)
  factory CoachCompleteModel.fromJson(Map<String, dynamic> json) {
    return CoachCompleteModel(
      coachUuid: (json['coach_UUID'] as num).toInt(),
      coachName: json['coach_name'] as String,
      wrestlingStyle: json['wrestling_style'] as String,
      clubUuid: (json['club_UUID'] as num).toInt(),
      clubName: json['club_name'] as String,
      clubCity: json['club_city'] as String,
    );
  }

  /// Convertim înapoi la un map JSON (dacă avem nevoie să trimitem cumva înapoi)
  Map<String, dynamic> toJson() {
    return {
      'coach_UUID': coachUuid,
      'coach_name': coachName,
      'wrestling_style': wrestlingStyle,
      'club_UUID': clubUuid,
      'club_name': clubName,
      'club_city': clubCity,
    };
  }

  @override
  String toString() {
    return 'CoachCompleteModel(coachUuid: $coachUuid, coachName: $coachName, '
        'wrestlingStyle: $wrestlingStyle, clubUuid: $clubUuid, '
        'clubName: $clubName, clubCity: $clubCity)';
  }
}
