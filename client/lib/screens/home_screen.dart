import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/trending_item.dart';
import 'library_screen.dart';
import 'add_song_url.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> savedSongs = [];

  @override
  void initState() {
    super.initState();
    _loadSavedSongs();
  }

  Future<void> _loadSavedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final clipsJson = prefs.getString('clips') ?? '[]';
    setState(() {
      savedSongs = List<Map<String, dynamic>>.from(jsonDecode(clipsJson));
    });
  }

  final List<TrendingItem> trendingItems = [
    TrendingItem(title: 'JENNIE - Mantra (Official)', artist: 'JENNIE', rank: 1),
    TrendingItem(title: "IU '바이, 썸머' (Bye summer)", artist: 'IU', rank: 2),
    TrendingItem(title: 'Heavy Is The Crown (ft. Li)', artist: 'League of Legends', rank: 3),
    TrendingItem(title: 'Heavy Is The Crown (ft. Li)', artist: 'League of Legends', rank: 4),
    TrendingItem(title: 'Heavy Is The Crown (ft. Li)', artist: 'League of Legends', rank: 5),
    TrendingItem(title: 'Heavy Is The Crown (ft. Li)', artist: 'League of Legends', rank: 6),
    TrendingItem(title: 'Heavy Is The Crown (ft. Li)', artist: 'League of Legends', rank: 7),
    TrendingItem(title: 'Heavy Is The Crown (ft. Li)', artist: 'League of Legends', rank: 8),
    TrendingItem(title: 'Heavy Is The Crown (ft. Li)', artist: 'League of Legends', rank: 9),
    TrendingItem(title: 'Heavy Is The Crown (ft. Li)', artist: 'League of Legends', rank: 10),
  ];

  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
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
  }

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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // 흰색 텍스트
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
                      prefixIcon: Icon(Icons.search, color: Colors.white), // 흰색 아이콘
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintStyle: TextStyle(color: Colors.white), // 흰색 힌트 텍스트
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
              if (savedSongs.isNotEmpty) ...[
                SizedBox(
                  height: 162,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: savedSongs.length,
                    itemBuilder: (context, index) {
                      final song = savedSongs[index];
                      return _buildSavedSongItem(song);
                    },
                  ),
                ),
              ],
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
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
    );
  }


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
                color: Colors.grey[800],
                image: DecorationImage(
                  image: AssetImage(item.imageUrl),
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
                      color: Colors.white, // 흰색 텍스트
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.artist,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.more_vert,
              color: Colors.white, // 흰색 아이콘
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedSongItem(Map<String, dynamic> song) {
    return Container(
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
    );
  }
}