class TrendingItem {
  final int rank;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final String videoId;
  final String viewCount;

  TrendingItem({
    required this.rank,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.videoId,
    required this.viewCount,
  });

  String get youtubeUrl => 'https://youtube.com/watch?v=$videoId';
}