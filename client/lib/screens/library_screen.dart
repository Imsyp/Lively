import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'add_song_url.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool isPlaylistsSelected = false;
  List<Map<String, dynamic>> liveData = [];

  final List<Map<String, String>> recentlyPlayed = [
    {"title": "인디 플리", "tracks": "128 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "킬링보이스 플리", "tracks": "33 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "콘서트 라이브 플리", "tracks": "48 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "비긴어게인 플리", "tracks": "10 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "버스킹 플리", "tracks": "14 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "유스케 플리", "tracks": "35 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "인디 플리", "tracks": "128 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "킬링보이스 플리", "tracks": "33 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "콘서트 라이브 플리", "tracks": "48 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "비긴어게인 플리", "tracks": "10 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "버스킹 플리", "tracks": "14 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "유스케 플리", "tracks": "35 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "인디 플리", "tracks": "128 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "킬링보이스 플리", "tracks": "33 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "콘서트 라이브 플리", "tracks": "48 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "비긴어게인 플리", "tracks": "10 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "버스킹 플리", "tracks": "14 tracks", "imageUrl": "assets/placeholder.jpg"},
    {"title": "유스케 플리", "tracks": "35 tracks", "imageUrl": "assets/placeholder.jpg"},
  ];

  int _currentIndex = 2; // 라이브러리 탭이 기본 선택된 상태

  @override
  void initState() {
    super.initState();
    _fetchLiveData(); // API 호출
  }

  Future<void> _fetchLiveData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/live'));

    if (response.statusCode == 200) {
      // 성공적으로 데이터를 가져왔을 때
      final List<dynamic> responseData = jsonDecode(response.body);

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
            icon: CircleAvatar(
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),
            onPressed: () {},
          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recently Played",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: recentlyPlayed.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.asset(
                        recentlyPlayed[index]["imageUrl"]!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        recentlyPlayed[index]["title"]!,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      subtitle: Text(
                        recentlyPlayed[index]["tracks"]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.play_arrow, color: Colors.white),
                      onTap: () {
                        // 재생 기능 추가 가능
                      },
                    );
                  },
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900], // 배경 색상을 어두운 색으로
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outlined),
            label: 'Add Song',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60, // 선택되지 않은 항목의 색상
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 2) {
            // Library를 선택했을 때 애니메이션 없이 이동
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const LibraryScreen(),
                transitionDuration: Duration.zero, // 애니메이션 없이 전환
              ),
            );
          } else if (index == 0) {
            // Home을 선택했을 때 애니메이션 없이 이동
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                transitionDuration: Duration.zero, // 애니메이션 없이 전환
              ),
            );
          } else {
            // Explore 화면으로 전환
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const AddSongUrlScreen(),
                transitionDuration: Duration.zero, // 애니메이션 없이 전환
              ),
            );
          }
        },
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