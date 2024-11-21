import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isPlaying = false;
  double _currentTime = 0;
  double _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      final controller = YoutubePlayerController(
        initialVideoId: widget.videoId,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          startAt: widget.startTime.toInt(),
          endAt: widget.endTime.toInt(),
          mute: false,
          hideControls: true,
          disableDragSeek: true,
          loop: true,
        ),
      );

      controller.addListener(() {
        if (!mounted) return;

        final position = controller.value.position.inSeconds.toDouble();
        
        // 종료 시간에 도달하면 시작 시간으로 돌아가기
        if (position >= widget.endTime) {
          controller.seekTo(Duration(seconds: widget.startTime.toInt()));
          controller.play();
        }

        setState(() {
          _isPlaying = controller.value.isPlaying;
          _currentTime = position;
          _totalDuration = widget.endTime - widget.startTime;
        });
      });
      
      setState(() {
        _controller = controller;
      });
    } catch (e) {
      print('플레이어 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
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
    final adjustedCurrentTime = _currentTime - widget.startTime;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.expand_more, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          if (_controller != null) ...[
            YoutubePlayer(
              controller: _controller!,
              showVideoProgressIndicator: false,
              onReady: () {
                setState(() {
                  _isPlayerReady = true;
                });
                // 준비되면 시작 시간으로 이동
                _controller!.seekTo(Duration(seconds: widget.startTime.toInt()));
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
                      value: adjustedCurrentTime.clamp(0, _totalDuration),
                      min: 0,
                      max: _totalDuration,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey[800],
                      onChanged: (value) {
                        if (_controller != null) {
                          final newPosition = value + widget.startTime;
                          setState(() {
                            _currentTime = newPosition;
                          });
                          _controller!.seekTo(Duration(seconds: newPosition.toInt()));
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(adjustedCurrentTime.clamp(0, _totalDuration)),
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
                      if (_controller != null) {
                        _controller!.seekTo(Duration(seconds: widget.startTime.toInt()));
                        _controller!.play();
                      }
                    },
                    iconSize: 40,
                  ),
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
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
                      if (_controller != null) {
                        _controller!.seekTo(Duration(seconds: widget.endTime.toInt() - 1));
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
  }
}