import 'package:get_it/get_it.dart';
import 'data/liked_cats_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<LikedCatsRepository>(() => LikedCatsRepository());
}
