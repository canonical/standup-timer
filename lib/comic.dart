import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  if (weekday == DateTime.monday || weekday == DateTime.wednesday || weekday == DateTime.friday) {
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
    final latestResponse = await http.get(Uri.parse("https://xkcd.com/info.0.json"));
    if (latestResponse.statusCode == 200) {
      final latestJson = json.decode(latestResponse.body);
      final maxNum = latestJson['num'];
      // Generate a random comic number between 1 and maxNum.
      final randomComicNum = Random().nextInt(maxNum) + 1;
      final randomResponse = await http.get(Uri.parse("https://xkcd.com/$randomComicNum/info.0.json"));
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
  const ComicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Comic>(
      future: fetchComic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final comic = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                Text(comic.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Image.network(comic.img),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(comic.alt),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}