class LiveItem {
  final String title;
  final String artist;
  final String imageUrl;

  LiveItem({
    required this.title,
    required this.artist,
    this.imageUrl = 'assets/placeholder.jpg',
  });

  factory LiveItem.fromJson(Map<String, dynamic> json) {
    return LiveItem(
      title: json['title'],
      artist: json['singer'] // 한글 처리
    );
  }
}