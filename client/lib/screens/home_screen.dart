import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/trending_item.dart';
import 'library_screen.dart';
import 'add_song_url.dart';
import 'player_screen.dart';
import '../material/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> liveData = [];
  List<TrendingItem> trendingItems = [];
  late final String apiKey;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    _fetchLiveData();
    _fetchTrendingVideos();
  }

  // 'Your Own Lives' 탭 아래에 삽입할 live 목록 fetch
  Future<void> _fetchLiveData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/live'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> responseData = jsonDecode(decodedBody);

        setState(() {
          liveData = responseData.map((item) {
            return {
              'id': item['id'].toString(),
              'title': item['title'] ?? 'Unknown',
              'singer': item['singer'] ?? 'Unknown',
              'thumbnailUrl': item['thumbnailUrl'] ?? 'assets/placeholder.jpg',
              'videoId': item['videoId'] ?? '',
              'startTime': item['startTime'] ?? 0.0,
              'endTime': item['endTime'] ?? 0.0,
            };
          }).toList();
        });
        
        print('Processed Live Data: $liveData');
      } else {
        print('Failed to load live data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching live data: $e');
    }
  }

  // 'Trending on This Week' 탭 아래에 삽입할 TredingVideos 목록 fetch
  Future<void> _fetchTrendingVideos() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/youtube/v3/videos?'
          'part=snippet,statistics&'
          'chart=mostPopular&'
          'videoCategoryId=10&'  // Music category
          'regionCode=KR&'       // Korea region
          'maxResults=10&'
          'key=$apiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        setState(() {
          trendingItems = List<TrendingItem>.from(items.asMap().entries.map((entry) {
            final item = entry.value;
            final snippet = item['snippet'];
            final statistics = item['statistics'];
            final titleParts = snippet['title'].toString().split(' - ');
            final artist = titleParts.length > 1 ? titleParts[0] : 'Unknown Artist';
            final title = titleParts.length > 1 ? titleParts[1] : snippet['title'];

            return TrendingItem(
              rank: entry.key + 1,
              title: title,
              artist: artist,
              thumbnailUrl: snippet['thumbnails']['high']['url'],
              videoId: item['id'],
              viewCount: _formatViewCount(statistics['viewCount']),
            );
          }));
        });
      } else {
        print('Failed to load trending videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching trending videos: $e');
    }
  }

  // viewCount 단위 변환
  String _formatViewCount(String viewCount) {
    final count = int.parse(viewCount);
    if (count > 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M views';
    } else if (count > 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K views';
    }
    return '$count views';
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

  // 전체 화면 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Hello, Sydev!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Your Own Lives',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 162,
                child: liveData.isNotEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: liveData.length,
                        itemBuilder: (context, index) {
                          final song = liveData[index];
                          return _buildSavedSongItem(song);
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 48,
                              color: Colors.grey[700],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No lives yet',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 23),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Trending on This Week',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 350,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trendingItems.length,
                  itemBuilder: (context, index) {
                    final item = trendingItems[index];
                    return _buildTrendingItem(item);
                  },
                ),
              ),
            ],
          ),
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
      )
    );
  }

  // fetch한 TrendingItems 기반으로 terdingItem tab 화면 구성
  Widget _buildTrendingItem(TrendingItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                '${item.rank}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: NetworkImage(item.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.artist} • ${item.viewCount}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                final url = 'https://youtube.com/watch?v=${item.videoId}';
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSongUrlScreen(
                      initialUrl: url,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 
  Widget _buildSavedSongItem(Map<String, dynamic> song) {
    return GestureDetector(
      onTap: () {
        print('Clicked song: $song');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              liveId: song['id'],
              thumbnailUrl: song['thumbnailUrl'],
              title: song['title'],
              singer: song['singer'],
              videoId: song['videoId'],
              startTime: song['startTime'],
              endTime: song['endTime'],
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[800],
                image: DecorationImage(
                  image: NetworkImage(song['thumbnailUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              song['title'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song['singer'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}