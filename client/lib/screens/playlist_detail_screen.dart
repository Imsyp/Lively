import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'player_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final String playlistTitle;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistTitle,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<Map<String, dynamic>> lives = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaylistLives();
  }

  Future<void> _fetchPlaylistLives() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/playlist/${widget.playlistId}/lives'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> responseData = jsonDecode(decodedBody);
        setState(() {
          lives = responseData.map((item) => {
            'id': item['id'],
            'title': item['title'] ?? 'Unknown',
            'singer': item['singer'] ?? 'Unknown',
            'thumbnailUrl': item['thumbnailUrl'] ?? 'assets/placeholder.jpg',
            'videoId': item['videoId'] ?? '',
            'startTime': item['startTime']?.toDouble() ?? 0.0,
            'endTime': item['endTime']?.toDouble() ?? 0.0,
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading playlist: $e')),
      );
    }
  }

  void _navigateToPlayer(Map<String, dynamic> live) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          liveId: live['id'],
          title: live['title'],
          singer: live['singer'],
          thumbnailUrl: live['thumbnailUrl'],
          videoId: live['videoId'],
          startTime: live['startTime'],
          endTime: live['endTime'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.playlistTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 추가 메뉴 옵션을 위한 공간
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lives.isEmpty
              ? const Center(
                  child: Text(
                    'No songs in this playlist',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: lives.length,
                  itemBuilder: (context, index) {
                    final live = lives[index];
                    return ListTile(
                      leading: Image.network(
                        live['thumbnailUrl']!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        live['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        live['singer']!,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () => _navigateToPlayer(live),
                      ),
                      onTap: () => _navigateToPlayer(live),
                    );
                  },
                ),
    );
  }
}