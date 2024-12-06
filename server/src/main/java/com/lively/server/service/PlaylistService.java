package com.lively.server.service;

import com.lively.server.domain.Live;
import com.lively.server.domain.Playlist;
import com.lively.server.repository.PlaylistRepository;
import lombok.RequiredArgsConstructor;
import org.bson.types.ObjectId;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PlaylistService {

    private final PlaylistRepository playlistRepository;

    public List<Playlist> getAllPlaylists() {
        return playlistRepository.findAll();
    }

    public Playlist getPlaylist(ObjectId id) {
        return playlistRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));
    }

    public List<Live> getPlaylistLives(ObjectId playlistId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));

        return playlist.getLives();
    }

    public void savePlaylist(String title, String imageUrl) {
        Playlist playlist = new Playlist();
        playlist.setTitle(title);
        playlist.setImageUrl(imageUrl);
        playlist.setLives(new ArrayList<>());

        playlistRepository.save(playlist);
    }

    // Playlist에 Live 추가
    public void addLiveToPlaylist(ObjectId playlistId, Live live) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));

        if (playlist.getLives() == null) {
            playlist.setLives(new ArrayList<>());
        }

        // 중복 체크
        boolean isDuplicate = playlist.getLives().stream()
                .anyMatch(existingLive -> existingLive.getId().equals(live.getId()));

        if (isDuplicate) {
            throw new IllegalStateException("이미 플레이리스트에 존재하는 라이브입니다.");
        }

        playlist.getLives().add(live);
        playlistRepository.save(playlist);
    }

    public void removeLiveFromPlaylist(ObjectId playlistId, ObjectId liveId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));

        boolean removed = playlist.getLives().removeIf(live -> live.getId().equals(liveId.toString()));

        if (!removed) {
            throw new RuntimeException("플레이리스트에서 해당 라이브를 찾을 수 없습니다.");
        }

        playlistRepository.save(playlist);
    }
}