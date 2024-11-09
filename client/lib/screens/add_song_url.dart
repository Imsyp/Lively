// add_song_url_screen.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'add_song_detail.dart';
import 'home_screen.dart';
import 'library_screen.dart';

class AddSongUrlScreen extends StatefulWidget {
  const AddSongUrlScreen({super.key});

  @override
  State<AddSongUrlScreen> createState() => _AddSongUrlScreenState();
}

class _AddSongUrlScreenState extends State<AddSongUrlScreen> {
  final TextEditingController _urlController = TextEditingController();

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

  void _loadVideo() {
    String url = _urlController.text;
    String? videoId;
    
    try {
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        videoId = YoutubePlayer.convertUrlToId(url);
      } else if (url.length == 11) {
        videoId = url;
      }
      
      if (videoId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddSongDetailScreen(videoId: videoId!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid YouTube URL or video ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load video. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Add Song'),
        leading: IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage('assets/profile.jpg'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Paste YouTube URL',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onFieldSubmitted: (_) => _loadVideo(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}