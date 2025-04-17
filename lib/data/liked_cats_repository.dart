import '../domain/liked_cat.dart';

class LikedCatsRepository {
  final List<LikedCat> _likedCats = [];

  List<LikedCat> getAll() => List.unmodifiable(_likedCats);

  void add(LikedCat cat) {
    _likedCats.add(cat);
  }

  void remove(LikedCat cat) {
    _likedCats.remove(cat);
  }

  /// Функция для фильтрации по породе
  List<LikedCat> filterByBreed(String breed) {
    return _likedCats
        .where((cat) => cat.breed.toLowerCase().contains(breed.toLowerCase()))
        .toList();
  }
}
