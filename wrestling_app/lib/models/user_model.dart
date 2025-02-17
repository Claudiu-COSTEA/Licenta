class UserModel {
  final int userUUID;
  final String userEmail;
  final String userFullName;
  final String userType; // Wrestling Club, Referee, Coach, Wrestler

  UserModel({
    required this.userUUID,
    required this.userEmail,
    required this.userFullName,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userUUID: json['user_UUID'],
      userEmail: json['user_email'],
      userFullName: json['user_full_name'],
      userType: json['user_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_UUID': userUUID,
      'user_email': userEmail,
      'user_full_name': userFullName,
      'user_type': userType,
    };
  }
}
