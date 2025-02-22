class WrestlerWeightCategory {
  final String wrestlingStyle;
  final String weightCategory;

  WrestlerWeightCategory({
    required this.wrestlingStyle,
    required this.weightCategory,
  });

  // Factory constructor to create an instance from JSON
  factory WrestlerWeightCategory.fromJson(Map<String, dynamic> json) {
    return WrestlerWeightCategory(
      wrestlingStyle: json['wrestling_style'],
      weightCategory: json['weight_category'],
    );
  }
}
