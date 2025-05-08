
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../cubits/liked_cats_cubit.dart';
import '../domain/liked_cat.dart';
import 'liked_cats_screen.dart';

class CatScreen extends StatefulWidget {
  const CatScreen({super.key});

  @override
  State<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends State<CatScreen> {
  String? _catImageUrl;
  String? _catBreed;
  String? _catDescription;
  bool _isLoading = true;
  bool _isOnline = true;

  late final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LikedCatsCubit>().loadLikedCats();
    });

    _connectivity = Connectivity();
    _connectivity.checkConnectivity().then(_onConnectivityChanged);
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    fetchCatImage();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  void _onConnectivityChanged(ConnectivityResult status) {
    final wasOnline = _isOnline;
    final nowOnline = status != ConnectivityResult.none;
    setState(() => _isOnline = nowOnline);

    if (!nowOnline && wasOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет подключения к сети'),
          duration: Duration(days: 1),
        ),
      );
    } else if (nowOnline && !wasOnline) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      fetchCatImage();
    }
  }

  Future<void> fetchCatImage() async {
    if (!_isOnline) return;

    setState(() => _isLoading = true);

    final apiKey = dotenv.env['CAT_API_KEY'];
    final url = Uri.parse(
      'https://api.thecatapi.com/v1/images/search?has_breeds=1&api_key=$apiKey',
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode != 200) throw Exception();

      final data = json.decode(resp.body) as List<dynamic>;
      final breedInfo = data[0]['breeds'][0];
      setState(() {
        _catBreed = breedInfo['name'] as String;
        _catDescription = breedInfo['description'] as String;
        _catImageUrl = data[0]['url'] as String;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  bool _onSwipe(int _, int? __, CardSwiperDirection dir) {
    if (dir == CardSwiperDirection.right) {
      _likeCat();
    } else {
      _dislikeCat();
    }
    return true;
  }

  void _likeCat() {
    if (!_isOnline) return;

    if (_catImageUrl != null && _catBreed != null && _catDescription != null) {
      final liked = LikedCat(
        imageUrl: _catImageUrl!,
        breed: _catBreed!,
        likedDate: DateTime.now(),
      );
      context.read<LikedCatsCubit>().addLikedCat(liked);
      setState(() {});
    }
    fetchCatImage();
  }

  void _dislikeCat() => fetchCatImage();

  @override
  Widget build(BuildContext context) {
    final likesCount = context.watch<LikedCatsCubit>().state.cats.length;

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
                cardBuilder:
                    (_, __, ___, ____) => _buildCard(context, likesCount),
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

  Widget _buildCard(BuildContext context, int likesCount) {
    if (!_isOnline && _catImageUrl == null) {
      return Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isLoading && _catBreed != null)
              Text(
                'Breed: $_catBreed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            const SizedBox(height: 10),
            if (_isLoading)
              const SizedBox(
                width: 300,
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_catImageUrl != null)
              GestureDetector(
                onTap: () {
                  if (_catDescription != null) {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder:
                            (_, __, ___) => _CatDescription(
                              imageUrl: _catImageUrl!,
                              description: _catDescription!,
                            ),
                      ),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: _catImageUrl!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
                  icon: const Icon(Icons.close),
                  label: const Text('Dislike'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _likeCat,
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  label: const Text('Like'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CatDescription extends StatelessWidget {
  final String imageUrl;
  final String description;

  const _CatDescription({required this.imageUrl, required this.description});

  @override
  Widget build(BuildContext context) {
    var screen_width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(228, 0, 0, 0),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(screen_width * 0.1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
