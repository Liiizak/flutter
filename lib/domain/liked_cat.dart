class LikedCat {
  final String imageUrl;
  final String breed;
  final DateTime likedDate;

  LikedCat({
    required this.imageUrl,
    required this.breed,
    required this.likedDate,
  });

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'breed': breed,
    'likedDate': likedDate.toIso8601String(),
  };

  factory LikedCat.fromJson(Map<String, dynamic> json) {
    return LikedCat(
      imageUrl: json['imageUrl'] as String,
      breed: json['breed'] as String,
      likedDate: DateTime.parse(json['likedDate'] as String),
    );
  }
}
