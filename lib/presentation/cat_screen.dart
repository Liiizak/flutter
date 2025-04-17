import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/liked_cats_cubit.dart';
import '../domain/liked_cat.dart';
import 'liked_cats_screen.dart';

class CatScreen extends StatefulWidget {
  const CatScreen({Key? key}) : super(key: key);

  @override
  State<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends State<CatScreen> {
  String? _catImageUrl;
  bool _isLoading = true;
  bool _hasError = false;
  GestureDetector? _imageWithTap;
  String? _catBreed;

  late final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  @override
  void initState() {
    super.initState();

    _connectivity = Connectivity();
    _connectivitySub = _connectivity.onConnectivityChanged.listen((status) {
      if (_hasError && status != ConnectivityResult.none) {
        fetchCatImage();
      }
    });

    fetchCatImage();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Widget getCard() {
    if (_hasError) {
      return Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 10),
                const Text('Нет подключения', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: fetchCatImage,
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final likesCount = context.watch<LikedCatsCubit>().state.cats.length;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                  'Breed: $_catBreed',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
            const SizedBox(height: 10),
            _isLoading ? const SizedBox() : _imageWithTap ?? const SizedBox(),
            const SizedBox(height: 20),
            Text(
              'Likes: $likesCount',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _dislikeCat,
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text('Dislike'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _likeCat,
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  label: const Text('Like'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 197, 135, 155),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchCatImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final url = Uri.parse(
      'https://api.thecatapi.com/v1/images/search?has_breeds=1&api_key=live_2L4N0cSJuh78pclx7XWNzrOvnMJS4pB1zJgILL1mtNO2plpcr8kdInJtYRkRnspl',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final data = json.decode(response.body) as List<dynamic>;
      setState(() {
        _catBreed = data[0]['breeds'][0]['name'] as String;
        _catImageUrl = data[0]['url'] as String;
        final description = data[0]['breeds'][0]['description'] as String;
        final image = Image.network(
          _catImageUrl!,
          width: 300,
          height: 300,
          fit: BoxFit.cover,
        );

        _imageWithTap = GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _CatDescription(description, image),
                ),
              ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: image,
          ),
        );

        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (direction == CardSwiperDirection.right) {
      _likeCat();
    } else {
      fetchCatImage();
    }
    return true;
  }

  void _likeCat() {
    if (_catImageUrl != null && _catBreed != null) {
      final likedCat = LikedCat(
        imageUrl: _catImageUrl!,
        breed: _catBreed!,
        likedDate: DateTime.now(),
      );
      context.read<LikedCatsCubit>().addLikedCat(likedCat);
    }
    fetchCatImage();
  }

  void _dislikeCat() => fetchCatImage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cats Tinder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LikedCatsScreen()),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: CardSwiper(
                cardBuilder: (_, __, ___, ____) => getCard(),
                cardsCount: 1,
                numberOfCardsDisplayed: 1,
                maxAngle: 30,
                allowedSwipeDirection: const AllowedSwipeDirection.only(
                  right: true,
                  left: true,
                ),
                onSwipe: _onSwipe,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatDescription extends StatelessWidget {
  final String fullInformation;
  final Image image;

  const _CatDescription(this.fullInformation, this.image, {Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.clear, size: 30),
                  padding: const EdgeInsets.only(top: 10, right: 10),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: image,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: Text(
                  fullInformation,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
