package com.lively.server.controller.dto;

import com.lively.server.domain.Live;
import com.lively.server.domain.Playlist;
import com.lively.server.service.PlaylistService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/playlist")
@RequiredArgsConstructor
public class PlaylistController {

    private final PlaylistService playlistService;

    @GetMapping
    public List<Playlist> getAllPlaylists() {
        return playlistService.getAllPlaylists();
    }

    @GetMapping("/{id}")
    public Playlist getPlaylist(@PathVariable Long id) {
        return playlistService.getPlaylist(id);
    }

    @GetMapping("/{id}/lives")
    public List<Live> getPlaylistLives(@PathVariable Long id) {
        return playlistService.getPlaylistLives(id);
    }

    @PostMapping("/add")
    public Playlist createPlaylist(@RequestBody Playlist playlist) {
        return playlistService.createPlaylist(playlist.getTitle(), playlist.getImageUrl());
    }

    @PostMapping("/{playlistId}/lives/{liveId}")
    public Playlist addLiveToPlaylist(@PathVariable Long playlistId, @PathVariable Long liveId) {
        return playlistService.addLiveToPlaylist(playlistId, liveId);
    }

    @DeleteMapping("/{playlistId}/lives/{liveId}")
    public void removeLiveFromPlaylist(@PathVariable Long playlistId, @PathVariable Long liveId) {
        playlistService.removeLiveFromPlaylist(playlistId, liveId);
    }
}