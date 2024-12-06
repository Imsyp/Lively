import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'now_playing_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NowPlayingProvider>(
      builder: (context, nowPlayingProvider, child) {
        if (nowPlayingProvider.currentLive == null) {
          return const SizedBox.shrink();
        }

        final live = nowPlayingProvider.currentLive!;
        final controller = nowPlayingProvider.youtubeController;

        return Stack(
          children: [
            // 숨겨진 YouTube 플레이어
            if (controller != null)
              Offstage(
                offstage: true,
                child: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: false,
                ),
              ),
            
            // 미니 플레이어 UI
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      liveId: live['id'],
                      title: live['title'],
                      singer: live['singer'],
                      thumbnailUrl: live['thumbnailUrl'],
                      videoId: live['videoId'],
                      startTime: live['startTime'],
                      endTime: live['endTime'],
                    ),
                  ),
                );
              },
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[800]!,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Image.network(
                      live['thumbnailUrl'],
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            live['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            live['singer'],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        nowPlayingProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        nowPlayingProvider.togglePlayPause();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}