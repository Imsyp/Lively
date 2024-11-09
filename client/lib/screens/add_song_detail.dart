import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_screen.dart';
import 'library_screen.dart';
import 'add_song_url.dart';

class AddSongDetailScreen extends StatefulWidget {
  final String videoId;
  
  const AddSongDetailScreen({super.key, required this.videoId});

  @override
  State<AddSongDetailScreen> createState() => _AddSongDetailScreenState();
}

class _AddSongDetailScreenState extends State<AddSongDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late YoutubePlayerController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _singerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  
  double _startTime = 0;
  double _endTime = 0;

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
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
    
    // 컨트롤러가 준비되면 한 번만 초기 duration을 설정
    _controller.addListener(() {
      if (_controller.value.isReady && !_controller.value.hasError && _endTime == 0) {
        setState(() {
          _endTime = _controller.metadata.duration.inSeconds.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _singerController.dispose();
    _descriptionController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _saveClip() async {
    if (_formKey.currentState!.validate()) {
      final clip = {
        'videoId': widget.videoId,
        'title': _titleController.text.trim(),
        'singer': _singerController.text.trim(),
        'description': _descriptionController.text.trim(),
        'lyrics': _lyricsController.text.trim(),
        'startTime': _startTime,
        'endTime': _endTime,
        'thumbnailUrl': YoutubePlayer.getThumbnail(
          videoId: widget.videoId,
        ),
      };

      final prefs = await SharedPreferences.getInstance();
      final clipsJson = prefs.getString('clips') ?? '[]';
      final clips = jsonDecode(clipsJson) as List<dynamic>;
      clips.add(clip);
      await prefs.setString('clips', jsonEncode(clips));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song clip added successfully')),
        );
        Navigator.pushNamed(context, '/library');
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      maxLines: maxLines,
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      } : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Add Song'),
      ),
      body: Column(
        children: [
          // 상단 고정 영역 - 영상 플레이어와 Time Slider
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blue,
                  onReady: () {
                    if (_endTime == 0) {
                      setState(() {
                        _endTime = _controller.metadata.duration.inSeconds.toDouble();
                      });
                    }
                  },
                ),
              ),
              // Time Range Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Select Time Range',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_controller.metadata.duration.inSeconds > 0) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RangeSlider(
                        values: RangeValues(_startTime, _endTime),
                        max: _controller.metadata.duration.inSeconds.toDouble(),
                        divisions: _controller.metadata.duration.inSeconds > 0 
                            ? _controller.metadata.duration.inSeconds 
                            : 100,
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey[800],
                        labels: RangeLabels(
                          Duration(seconds: _startTime.toInt()).toString().split('.').first,
                          Duration(seconds: _endTime.toInt()).toString().split('.').first,
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _startTime = values.start;
                            _endTime = values.end;
                          });
                          _controller.seekTo(Duration(seconds: _startTime.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Duration(seconds: _startTime.toInt()).toString().split('.').first,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            Duration(seconds: _endTime.toInt()).toString().split('.').first,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ] else const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 중간 스크롤 영역
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: _titleController,
                      hintText: 'Please enter a title.',
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _singerController,
                      hintText: 'Please enter a singer.',
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Please enter a description.',
                      isRequired: false,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _lyricsController,
                      hintText: 'Please enter lyrics.',
                      isRequired: false,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // 하단 고정 영역 - Add 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveClip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
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