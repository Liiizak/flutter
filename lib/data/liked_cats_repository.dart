import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/liked_cat.dart';


class LikedCatsRepository {
  static const _prefsKey = 'liked_cats';
  final List<LikedCat> _likedCats = [];

  LikedCatsRepository();

  Future<void> init() async {
    await _loadFromPrefs();
  }

  List<LikedCat> getAll() => List.unmodifiable(_likedCats);

  Future<void> add(LikedCat cat) async {
    _likedCats.add(cat);
    await _saveToPrefs();
  }

  Future<void> remove(LikedCat cat) async {
    _likedCats.remove(cat);
    await _saveToPrefs();
  }

  List<LikedCat> filterByBreed(String breed) {
    return _likedCats
        .where((cat) => cat.breed.toLowerCase().contains(breed.toLowerCase()))
        .toList();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_prefsKey) ?? [];
    _likedCats.clear();
    for (var jsonStr in data) {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      _likedCats.add(LikedCat.fromJson(map));
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _likedCats.map((cat) => json.encode(cat.toJson())).toList();
    await prefs.setStringList(_prefsKey, data);
  }
}
