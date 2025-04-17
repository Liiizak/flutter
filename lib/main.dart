import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/liked_cats_cubit.dart';
import 'data/liked_cats_repository.dart';
import 'service_locator.dart';
import 'presentation/cat_screen.dart';

void main() {
  setupLocator();

  runApp(
    BlocProvider(
      create: (_) => LikedCatsCubit(repository: getIt<LikedCatsRepository>()),
      child: const CatApp(),
    ),
  );
}

class CatApp extends StatelessWidget {
  const CatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cats Tinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const CatScreen(),
    );
  }
}
