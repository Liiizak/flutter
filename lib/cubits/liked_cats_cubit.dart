import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/liked_cat.dart';
import '../data/liked_cats_repository.dart';

class LikedCatsState {
  final List<LikedCat> cats;
  final String filter;
  final bool isLoading;
  final String? error;

  LikedCatsState({
    required this.cats,
    this.filter = '',
    this.isLoading = false,
    this.error,
  });

  LikedCatsState copyWith({
    List<LikedCat>? cats,
    String? filter,
    bool? isLoading,
    String? error,
  }) {
    return LikedCatsState(
      cats: cats ?? this.cats,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LikedCatsCubit extends Cubit<LikedCatsState> {
  final LikedCatsRepository repository;

  LikedCatsCubit({required this.repository})
    : super(LikedCatsState(cats: repository.getAll()));

  void addLikedCat(LikedCat cat) {
    repository.add(cat);
    emit(state.copyWith(cats: repository.getAll()));
  }

  void removeLikedCat(LikedCat cat) {
    repository.remove(cat);
    emit(state.copyWith(cats: repository.getAll()));
  }

  void filterCats(String breed) {
    emit(state.copyWith(filter: breed));
  }
}
