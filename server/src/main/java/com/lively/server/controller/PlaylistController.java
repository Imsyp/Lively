package com.lively.server.controller;

import com.lively.server.controller.dto.PlaylistRequest;
import com.lively.server.domain.Live;
import com.lively.server.domain.Playlist;
import com.lively.server.service.LiveService;
import com.lively.server.service.PlaylistService;
import lombok.RequiredArgsConstructor;
import org.bson.types.ObjectId;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/playlist")
@RequiredArgsConstructor
public class PlaylistController {

    private final PlaylistService playlistService;
    private final LiveService liveService;

    @GetMapping
    public List<Playlist> getAllPlaylists() {
        return playlistService.getAllPlaylists();
    }

    @GetMapping("/{id}")
    public Playlist getPlaylist(@PathVariable("id") String id) {
        ObjectId objectId = new ObjectId(id);
        return playlistService.getPlaylist(objectId);
    }

    @GetMapping("/{id}/lives")
    public List<Live> getPlaylistLives(@PathVariable("id") String id) {
        ObjectId objectId = new ObjectId(id);
        return playlistService.getPlaylistLives(objectId);
    }

    @PostMapping("/add")
    public ResponseEntity<Void> createPlaylist(@RequestBody PlaylistRequest playlistRequest) {
        playlistService.savePlaylist(playlistRequest.getTitle(), playlistRequest.getImageUrl());
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @PostMapping("/{playlistId}/{liveId}")
    public ResponseEntity<Void> addLiveToPlaylist(@PathVariable("playlistId") String playlistId, @PathVariable("liveId") String liveId) {
        ObjectId objectIdPL = new ObjectId(playlistId);
        ObjectId objectIdLV = new ObjectId(liveId);

        playlistService.addLiveToPlaylist(objectIdPL, liveService.getLive(objectIdLV).get());
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @DeleteMapping("/{playlistId}/{liveId}")
    public ResponseEntity<Void> removeLiveFromPlaylist(@PathVariable("playlistId") String playlistId, @PathVariable("liveId") String liveId) {
        ObjectId objectIdPL = new ObjectId(playlistId);
        ObjectId objectIdLV = new ObjectId(liveId);
        playlistService.removeLiveFromPlaylist(objectIdPL, objectIdLV);
        return new ResponseEntity<>(HttpStatus.OK);
    }
}