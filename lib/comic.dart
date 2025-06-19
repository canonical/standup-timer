import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/timer_controls.dart';

class Comic {
  final String title;
  final String img;
  final String alt;

  Comic({required this.title, required this.img, required this.alt});

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      title: json['title'],
      img: json['img'],
      alt: json['alt'],
    );
  }
}

Future<Comic> fetchComic() async {
  final weekday = DateTime.now().weekday; // Monday=1, Tuesday=2, etc.
  if (weekday == DateTime.monday ||
      weekday == DateTime.wednesday ||
      weekday == DateTime.friday) {
    // Fetch the latest XKCD comic on Monday, Wednesday, or Friday.
    final response = await http.get(Uri.parse("https://xkcd.com/info.0.json"));
    if (response.statusCode == 200) {
      return Comic.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load latest comic');
    }
  } else {
    // Otherwise, fetch a random safe-for-work XKCD comic.
    // First, get the latest comic to know the maximum comic number.
    final latestResponse =
        await http.get(Uri.parse("https://xkcd.com/info.0.json"));
    if (latestResponse.statusCode == 200) {
      final latestJson = json.decode(latestResponse.body);
      final maxNum = latestJson['num'];
      // Generate a random comic number between 1 and maxNum.
      final randomComicNum = Random().nextInt(maxNum) + 1;
      final randomResponse = await http
          .get(Uri.parse("https://xkcd.com/$randomComicNum/info.0.json"));
      if (randomResponse.statusCode == 200) {
        return Comic.fromJson(json.decode(randomResponse.body));
      } else {
        throw Exception('Failed to load random comic');
      }
    } else {
      throw Exception('Failed to load latest comic for random selection');
    }
  }
}

class ComicScreen extends StatelessWidget {
  final bool showTimerControls;
  final bool isRunning;
  final bool isDisabled;
  final VoidCallback? onToggleTimer;
  final VoidCallback? onResetTimer;

  const ComicScreen({
    Key? key,
    this.showTimerControls = false,
    this.isRunning = false,
    this.isDisabled = false,
    this.onToggleTimer,
    this.onResetTimer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Comic>(
      future: fetchComic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
            'An error occurred while trying to connect to the server.\nPlease check your connection or try again later.',
            textAlign: TextAlign.center,
          ));
        } else if (snapshot.hasData) {
          final comic = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      comic.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight -
                          (showTimerControls
                              ? 180
                              : 120), // Reserve space for controls if needed
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Image.network(
                        comic.img,
                        fit: BoxFit.contain,
                        width: constraints.maxWidth - 32,
                        height: constraints.maxHeight -
                            (showTimerControls ? 180 : 120),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                              child: Text('Failed to load image'));
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      comic.alt,
                      style: const TextStyle(
                          fontSize: 14, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (showTimerControls) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TimerControls(
                        isRunning: isRunning,
                        isDisabled: isDisabled,
                        onToggleTimer: onToggleTimer ?? () {},
                        onResetTimer: onResetTimer ?? () {},
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
