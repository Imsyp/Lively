import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectPlaylistScreen extends StatefulWidget {
  final String liveId;
  
  const SelectPlaylistScreen({
    super.key, 
    required this.liveId,
  });

  @override
  State<SelectPlaylistScreen> createState() => _SelectPlaylistScreenState();
}

class _SelectPlaylistScreenState extends State<SelectPlaylistScreen> {
  List<Map<String, dynamic>> playlists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/playlist'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> responseData = jsonDecode(decodedBody);
        
        setState(() {
          playlists = responseData.map((item) {
            final lives = item['lives'] as List<dynamic>?;
            return {
              'id': item['id'],
              'title': item['title'],
              'imageUrl': lives != null && lives.isNotEmpty 
                  ? lives[0]['thumbnailUrl'] 
                  : 'assets/placeholder.jpg',
              'tracks': '${lives?.length ?? 0} tracks'
            };
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading playlists: $e')),
      );
    }
  }

  Future<void> _addToPlaylist(String playlistId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/playlist/$playlistId/${widget.liveId}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // 화면 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song added to playlist successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add song to playlist')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Add to Playlist'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  leading: Image.network(
                    playlist['imageUrl']!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    playlist['title']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    playlist['tracks']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () => _addToPlaylist(playlist['id']),
                );
              },
            ),
    );
  }
}