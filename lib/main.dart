import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CatApp());
}

class CatApp extends StatelessWidget {
  const CatApp({super.key});

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

class CatScreen extends StatefulWidget {
  const CatScreen({super.key});

  @override
  State<CatScreen> createState() => _CatScreenState();
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _CatDescription extends StatelessWidget {
  final String fullInformation;
  final Image image;

  const _CatDescription(this.fullInformation, this.image);

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

class _CatScreenState extends State<CatScreen> {
  int _counter = 0;
  String? _catImageUrl;
  bool _isLoading = true;
  GestureDetector? _imageWithTap;
  String? _catBreed;

  @override
  void initState() {
    super.initState();
    fetchCatImage();
  }

  Widget getCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            _isLoading ? const SizedBox() : _imageWithTap!,
            const SizedBox(height: 20),
            Text(
              'Likes: $_counter',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  onPressed: _dislikeCat,
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: 'Dislike',
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(width: 10),
                CustomButton(
                  onPressed: _likeCat,
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  label: 'Like',
                  backgroundColor: const Color.fromARGB(255, 197, 135, 155),
                  foregroundColor: Colors.white,
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
    });

    final url = Uri.parse(
      'https://api.thecatapi.com/v1/images/search?has_breeds=1&api_key=live_2L4N0cSJuh78pclx7XWNzrOvnMJS4pB1zJgILL1mtNO2plpcr8kdInJtYRkRnspl',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _catBreed = data[0]['breeds'][0]['name'];
        _catImageUrl = data[0]['url'];
        String fullInformation = data[0]['breeds'][0]['description'];
        Image image = Image.network(_catImageUrl!, width: 300, height: 300);

        _imageWithTap = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _CatDescription(fullInformation, image),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: image,
          ),
        );

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (direction == CardSwiperDirection.right) {
      _counter++;
    }
    fetchCatImage();
    return true;
  }

  void _likeCat() {
    setState(() {
      _counter++;
    });
    fetchCatImage();
  }

  void _dislikeCat() {
    fetchCatImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Cats Tinder'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: CardSwiper(
                cardBuilder:
                    (
                      context,
                      index,
                      horizontalThresholdPercentage,
                      verticalThresholdPercentage,
                    ) => getCard(),
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
