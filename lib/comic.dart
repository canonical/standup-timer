import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'widgets/timer_controls.dart';

class Comic {
  final String title;
  final String img;
  final String alt;
  final int num;

  Comic({required this.title, required this.img, required this.alt, required this.num});

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      title: json['title'],
      img: json['img'],
      alt: json['alt'],
      num: json['num'],
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

class ComicScreen extends StatefulWidget {
  final bool showTimerControls;
  final bool isRunning;
  final bool isDisabled;
  final VoidCallback? onToggleTimer;
  final VoidCallback? onResetTimer;

  const ComicScreen({
    super.key,
    this.showTimerControls = false,
    this.isRunning = false,
    this.isDisabled = false,
    this.onToggleTimer,
    this.onResetTimer,
  });

  @override
  State<ComicScreen> createState() => _ComicScreenState();
}

class _ComicScreenState extends State<ComicScreen> {
  Future<Comic>? _comicFuture;

  @override
  void initState() {
    super.initState();
    _comicFuture = fetchComic();
  }

  void _refreshComic() {
    setState(() {
      _comicFuture = fetchComic();
    });
  }

  void _showImageModal(BuildContext context, Comic comic) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Close on background tap
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
              // Image and caption container
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.95,
                  maxHeight: MediaQuery.of(context).size.height * 0.95,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image with zoom capability
                    Expanded(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.network(
                          comic.img,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('Failed to load image', style: TextStyle(color: Colors.white)));
                          },
                        ),
                      ),
                    ),
                    // Caption
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black87,
                      child: Text(
                        comic.alt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FutureBuilder<Comic>(
      future: _comicFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final comic = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Column(
                    children: [
                      // Title on its own row with normal padding
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          comic.title, 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight - (widget.showTimerControls ? 180 : 120), // Reserve space for controls if needed
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () => _showImageModal(context, comic),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Image.network(
                                comic.img,
                                fit: BoxFit.contain,
                                width: constraints.maxWidth - 32,
                                height: constraints.maxHeight - (widget.showTimerControls ? 180 : 120),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Text('Failed to load image'));
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          comic.alt,
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.showTimerControls) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: TimerControls(
                            isRunning: widget.isRunning,
                            isDisabled: widget.isDisabled,
                            onToggleTimer: widget.onToggleTimer ?? () {},
                            onResetTimer: widget.onResetTimer ?? () {},
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Action buttons aligned with title
                  Positioned(
                    top: 16, // Match the top padding of the title
                    right: 16, // Match the horizontal padding
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Copy URL button
                        IconButton(
                          icon: Icon(
                            Icons.link,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          tooltip: 'Copy comic URL',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: () {
                            final url = 'https://xkcd.com/${comic.num}/';
                            Clipboard.setData(ClipboardData(text: url));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Comic URL copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        // Refresh button
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          tooltip: 'Refresh comic',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: _refreshComic,
                        ),
                      ],
                    ),
                  ),
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