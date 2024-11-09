// lib/models/live_item.dart
class LiveItem {
  final String title;
  final String artist;
  final String imageUrl;

  LiveItem({
    required this.title,
    required this.artist,
    this.imageUrl = 'assets/placeholder.jpg',
  });
}