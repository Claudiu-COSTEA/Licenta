class Wrestler {
  final int wrestlerUUID;
  final int coachUUID;
  final String wrestlingStyle; // Greco Roman, Freestyle, Women

  Wrestler({
    required this.wrestlerUUID,
    required this.coachUUID,
    required this.wrestlingStyle,
  });

  factory Wrestler.fromJson(Map<String, dynamic> json) {
    return Wrestler(
      wrestlerUUID: json['wrestler_UUID'],
      coachUUID: json['coach_UUID'],
      wrestlingStyle: json['wrestling_style'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wrestler_UUID': wrestlerUUID,
      'coach_UUID': coachUUID,
      'wrestling_style': wrestlingStyle,
    };
  }
}
