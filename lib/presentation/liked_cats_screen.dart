import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/liked_cats_cubit.dart';

class LikedCatsScreen extends StatelessWidget {
  const LikedCatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LikedCatsCubit, LikedCatsState>(
      builder: (context, state) {
        final filteredCats =
            state.filter.isEmpty
                ? state.cats
                : state.cats
                    .where(
                      (cat) => cat.breed.toLowerCase().contains(
                        state.filter.toLowerCase(),
                      ),
                    )
                    .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Лайкнутые котики')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Фильтр по породе',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    context.read<LikedCatsCubit>().filterCats(value);
                  },
                ),
              ),
              Expanded(
                child:
                    state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredCats.isEmpty
                        ? const Center(
                          child: Text('Нет котиков для отображения'),
                        )
                        : ListView.builder(
                          itemCount: filteredCats.length,
                          itemBuilder: (context, index) {
                            final cat = filteredCats[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: ListTile(
                                leading: Image.network(
                                  cat.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const CircularProgressIndicator();
                                  },
                                ),
                                title: Text(cat.breed),
                                subtitle: Text(
                                  'Лайк: ${cat.likedDate.toLocal().toString().split('.').first}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<LikedCatsCubit>()
                                        .removeLikedCat(cat);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
