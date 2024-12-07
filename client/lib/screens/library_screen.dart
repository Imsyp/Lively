import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'add_song_url.dart';
import 'create_playlist_screen.dart';
import 'playlist_detail_screen.dart';
import '../material/mini_player.dart';
import '../config/env.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool isPlaylistsSelected = false;
  List<Map<String, dynamic>> liveData = [];
  List<Map<String, dynamic>> playlists = [];
  int _selectedIndex = 2;
  
  @override
  void initState() {
    super.initState();
    _fetchLiveData(); // API 호출
    _fetchPlaylists();
  }

  Future<void> _fetchLiveData() async {
    final host = EnvConfig.instance.host;
    final port = EnvConfig.instance.port;
    final response = await http.get(
      Uri.parse('http://$host:$port/live'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      
      // 성공적으로 데이터를 가져왔을 때
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> responseData = jsonDecode(decodedBody);
      setState(() {
        liveData = responseData.map((item) {
          return {
            'title': item['title'] ?? 'Unknown',
            'singer': item['singer'] ?? 'Unknown',
            'thumbnailUrl': item['thumbnailUrl'] ?? 'assets/placeholder.jpg',
          };
        }).toList();
      });
    } else {
      // 실패한 경우
      print('Failed to load live data');
    }
  }

  Future<void> _fetchPlaylists() async {
    final host = EnvConfig.instance.host;
    final port = EnvConfig.instance.port;
    try {
      final response = await http.get(
        Uri.parse('http://$host:$port/playlist'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      
      if (response.statusCode == 200) {
        // UTF-8로 디코딩
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> responseData = jsonDecode(decodedBody);
        
        setState(() {
          playlists = responseData.map((item) {
            // 플레이리스트의 lives 중 첫 번째 곡의 썸네일을 가져오기
            final lives = item['lives'] as List<dynamic>?;
            final thumbnailUrl = lives != null && lives.isNotEmpty 
                ? lives[0]['thumbnailUrl'] 
                : 'https://img.youtube.com/vi/JaeQtCPr6AI/0.jpg';
            
            return {
              'id': item['id'],
              'title': item['title'],
              'imageUrl': thumbnailUrl,  // 첫 번째 곡의 썸네일 사용
              'tracks': '${lives?.length ?? 0} tracks'
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching playlists: $e');
    }
  }

  // Navigation을 통한 화면 이동
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LibraryScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AddSongUrlScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const CircleAvatar(
              radius: 15,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton("Playlists", isPlaylistsSelected),
                _buildTabButton("Songs", !isPlaylistsSelected),
              ],
            ),
            const SizedBox(height: 16),
            if (isPlaylistsSelected) ...[
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Image.network(
                            playlists[index]["imageUrl"]!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            playlists[index]["title"]!,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Text(
                            playlists[index]["tracks"]!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(Icons.play_arrow, color: Colors.white),
                          onTap: () {
                            // PlaylistDetailScreen으로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistDetailScreen(
                                  playlistId: playlists[index]["id"]!,
                                  playlistTitle: playlists[index]["title"]!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreatePlaylistScreen(),
                                ),
                              );
                              
                              if (result == true) {
                                _fetchPlaylists(); // 새로운 플레이리스트 생성 후 목록 새로고침
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.add, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text(
                                    'New',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView.builder(
                  itemCount: liveData.length,
                  itemBuilder: (context, index) {
                    final song = liveData[index];
                    return ListTile(
                      leading: Image.network(
                        song['thumbnailUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        song['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        song['singer'],
                        style: const TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.play_arrow, color: Colors.white),
                      onTap: () {
                        // 재생 기능 추가 가능
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          BottomNavigationBar(
            backgroundColor: Colors.grey[900],
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: 1,
            onTap: _onNavItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.white), // 흰색 아이콘
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outlined),
                label: 'Add Song',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music, color: Colors.white), // 흰색 아이콘
                label: 'Library',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPlaylistsSelected = (text == "Playlists");
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}