import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/liked_cat.dart';
import '../data/liked_cats_repository.dart';

class LikedCatsState {
  final List<LikedCat> cats;
  final String filter;
  final bool isLoading;

  LikedCatsState({
    required this.cats,
    this.filter = '',
    this.isLoading = false,
  });

  LikedCatsState copyWith({
    List<LikedCat>? cats,
    String? filter,
    bool? isLoading,
  }) {
    return LikedCatsState(
      cats: cats ?? this.cats,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LikedCatsCubit extends Cubit<LikedCatsState> {
  final LikedCatsRepository repository;

  LikedCatsCubit({required this.repository})
    : super(LikedCatsState(cats: repository.getAll()));

  Future<void> addLikedCat(LikedCat cat) async {
    emit(state.copyWith(isLoading: true));
    await repository.add(cat);
    emit(state.copyWith(cats: repository.getAll(), isLoading: false));
  }

  Future<void> removeLikedCat(LikedCat cat) async {
    emit(state.copyWith(isLoading: true));
    await repository.remove(cat);
    emit(state.copyWith(cats: repository.getAll(), isLoading: false));
  }

  void filterCats(String breed) {
    emit(state.copyWith(filter: breed));
  }

  void loadLikedCats() {
    final all = repository.getAll();
    emit(state.copyWith(cats: all));
  }
}
