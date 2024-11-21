package com.lively.server.service;

import com.lively.server.domain.Live;
import com.lively.server.domain.Playlist;
import com.lively.server.repository.LiveRepository;
import com.lively.server.repository.PlaylistRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlaylistService {

    private final PlaylistRepository playlistRepository;
    private final LiveRepository liveRepository;

    public List<Playlist> getAllPlaylists() {
        return playlistRepository.findAll();
    }

    public Playlist getPlaylist(Long id) {
        return playlistRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));
    }

    public List<Live> getPlaylistLives(Long playlistId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));

        return playlist.getLives();
    }

    public Playlist createPlaylist(String title, String imageUrl) {
        Playlist playlist = new Playlist();
        playlist.setTitle(title);
        playlist.setImageUrl(imageUrl);

        return playlistRepository.save(playlist);
    }

    public Playlist addLiveToPlaylist(Long playlistId, Long liveId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));

        Live live = liveRepository.findById(liveId)
                .orElseThrow(() -> new RuntimeException("Live not found"));

        playlist.getLives().add(live);
        return playlistRepository.save(playlist);
    }

    public void removeLiveFromPlaylist(Long playlistId, Long liveId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));

        playlist.getLives().removeIf(live -> live.getId().equals(liveId));
        playlistRepository.save(playlist);
    }
}