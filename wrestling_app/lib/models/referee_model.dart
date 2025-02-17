class Referee {
  final int refereeUUID;
  final String wrestlingStyle;

  Referee({
    required this.refereeUUID,
    required this.wrestlingStyle,
  });

  factory Referee.fromJson(Map<String, dynamic> json) {
    return Referee(
      refereeUUID: json['referee_UUID'],
      wrestlingStyle: json['wrestling_style'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referee_UUID': refereeUUID,
      'wrestling_style': wrestlingStyle,
    };
  }
}
