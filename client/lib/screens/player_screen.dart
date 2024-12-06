import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import 'select_playlist_screen.dart';
import '../material/now_playing_provider.dart';
class PlayerScreen extends StatefulWidget {
  final String liveId;
  final String thumbnailUrl;
  final String title;
  final String singer;
  final String videoId;
  final double startTime;
  final double endTime;

  const PlayerScreen({
    super.key,
    required this.liveId,
    required this.thumbnailUrl,
    required this.title,
    required this.singer,
    required this.videoId,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late NowPlayingProvider _nowPlayingProvider;
  bool _isPlayerReady = false;
  double _currentTime = 0;
  double _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _nowPlayingProvider = Provider.of<NowPlayingProvider>(context, listen: false);
    
    // 현재 재생 중인 곡 정보를 Provider에 설정
    final currentLive = {
      'id': widget.liveId,
      'title': widget.title,
      'singer': widget.singer,
      'thumbnailUrl': widget.thumbnailUrl,
      'videoId': widget.videoId,
      'startTime': widget.startTime,
      'endTime': widget.endTime,
    };
    
    _nowPlayingProvider.setCurrentLive(currentLive);
    _totalDuration = widget.endTime - widget.startTime;
  }

  void _togglePlayPause() {
    _nowPlayingProvider.togglePlayPause();
  }

  String _formatDuration(double seconds) {
    Duration duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingProvider>(
      builder: (context, nowPlayingProvider, child) {
        final controller = nowPlayingProvider.youtubeController;
        final isPlaying = nowPlayingProvider.isPlaying;
        
        if (controller != null) {
          _currentTime = controller.value.position.inSeconds.toDouble();
        }
        
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.expand_more, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.grey[900],
                onSelected: (value) {
                  if (value == 'add_to_playlist') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectPlaylistScreen(
                          liveId: widget.liveId,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'add_to_playlist',
                    child: Row(
                      children: const [
                        Icon(Icons.playlist_add, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Add to Playlist',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              if (controller != null) ...[
                YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: false,
                  onReady: () {
                    setState(() {
                      _isPlayerReady = true;
                    });
                  },
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.singer,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Slider(
                          value: (_currentTime - widget.startTime).clamp(0, _totalDuration),
                          min: 0,
                          max: _totalDuration,
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey[800],
                          onChanged: (value) {
                            if (controller != null) {
                              final newPosition = value + widget.startTime;
                              controller.seekTo(Duration(seconds: newPosition.toInt()));
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration((_currentTime - widget.startTime).clamp(0, _totalDuration)),
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              Text(
                                _formatDuration(_totalDuration),
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Colors.white),
                        onPressed: () {},
                        iconSize: 28,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        onPressed: () {
                          if (controller != null) {
                            controller.seekTo(Duration(seconds: widget.startTime.toInt()));
                          }
                        },
                        iconSize: 40,
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                          ),
                          onPressed: _togglePlayPause,
                          iconSize: 40,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        onPressed: () {
                          if (controller != null) {
                            controller.seekTo(Duration(seconds: widget.endTime.toInt() - 1));
                          }
                        },
                        iconSize: 40,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.repeat, color: Colors.white),
                        onPressed: () {},
                        iconSize: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}