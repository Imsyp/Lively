// lib/models/trending_item.dart
class TrendingItem {
  final String title;
  final String artist;
  final String imageUrl;
  final int rank;

  TrendingItem({
    required this.title,
    required this.artist,
    required this.rank,
    this.imageUrl = 'assets/placeholder.jpg',
  });
}