import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class NowPlayingProvider extends ChangeNotifier {
  Map<String, dynamic>? currentLive;
  bool isPlaying = false;
  YoutubePlayerController? youtubeController;

  void setCurrentLive(Map<String, dynamic> live) {
    currentLive = live;
    isPlaying = true;
    
    // 새로운 곡이 선택되면 YouTube Player Controller를 초기화
    if (youtubeController == null || youtubeController?.metadata.videoId != live['videoId']) {
      youtubeController?.dispose(); // 이전 컨트롤러 해제
      
      youtubeController = YoutubePlayerController(
        initialVideoId: live['videoId'],
        flags: YoutubePlayerFlags(
          autoPlay: true,
          startAt: live['startTime'].toInt(),
          endAt: live['endTime'].toInt(),
          mute: false,
          hideControls: true,
          disableDragSeek: true,
          loop: true,
        ),
      );

      youtubeController?.addListener(_youtubeListener);
    }
    
    notifyListeners();
  }

  void _youtubeListener() {
    if (youtubeController != null) {
      final position = youtubeController!.value.position.inSeconds.toDouble();
      if (position >= currentLive!['endTime']) {
        youtubeController!.seekTo(Duration(seconds: currentLive!['startTime'].toInt()));
        youtubeController!.play();
      }
      isPlaying = youtubeController!.value.isPlaying;
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (youtubeController != null) {
      if (isPlaying) {
        youtubeController!.pause();
      } else {
        youtubeController!.play();
      }
      isPlaying = !isPlaying;
      notifyListeners();
    }
  }

  void clearCurrentLive() {
    youtubeController?.dispose();
    youtubeController = null;
    currentLive = null;
    isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    youtubeController?.dispose();
    super.dispose();
  }
}