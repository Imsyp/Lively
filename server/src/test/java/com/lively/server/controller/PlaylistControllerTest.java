package com.lively.server.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lively.server.controller.dto.PlaylistRequest;
import com.lively.server.domain.Live;
import com.lively.server.domain.Playlist;
import com.lively.server.service.LiveService;
import com.lively.server.service.PlaylistService;
import org.bson.types.ObjectId;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PlaylistController.class)
class PlaylistControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PlaylistService playlistService;

    @MockBean
    private LiveService liveService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void getAllPlaylists_ShouldReturnList() throws Exception {
        // Given
        List<Playlist> playlists = Arrays.asList(
                new Playlist(), new Playlist()
        );
        when(playlistService.getAllPlaylists()).thenReturn(playlists);

        // When & Then
        mockMvc.perform(get("/playlist"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));
    }

    @Test
    void getPlaylist_ShouldReturnPlaylist() throws Exception {
        // Given
        ObjectId id = new ObjectId();
        Playlist playlist = new Playlist();
        playlist.setTitle("Test Playlist");

        when(playlistService.getPlaylist(id)).thenReturn(playlist);

        // When & Then
        mockMvc.perform(get("/playlist/" + id.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Test Playlist"));
    }

    @Test
    void getPlaylistLives_ShouldReturnLivesList() throws Exception {
        // Given
        ObjectId id = new ObjectId();
        List<Live> lives = Arrays.asList(
                new Live(), new Live()
        );
        when(playlistService.getPlaylistLives(id)).thenReturn(lives);

        // When & Then
        mockMvc.perform(get("/playlist/" + id.toString() + "/lives"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));
    }

    @Test
    void createPlaylist_ShouldReturnCreated() throws Exception {
        // Given
        PlaylistRequest request = new PlaylistRequest();
        request.setTitle("New Playlist");
        request.setImageUrl("http://example.com/image.jpg");

        // When & Then
        mockMvc.perform(post("/playlist/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated());

        verify(playlistService).savePlaylist(request.getTitle(), request.getImageUrl());
    }

    @Test
    void addLiveToPlaylist_ShouldReturnOk() throws Exception {
        // Given
        ObjectId playlistId = new ObjectId();
        ObjectId liveId = new ObjectId();
        Live live = new Live();

        when(liveService.getLive(liveId)).thenReturn(Optional.of(live));

        // When & Then
        mockMvc.perform(post("/playlist/" + playlistId.toString() + "/" + liveId.toString()))
                .andExpect(status().isOk());

        verify(playlistService).addLiveToPlaylist(eq(playlistId), any(Live.class));
    }

    @Test
    void removeLiveFromPlaylist_ShouldReturnOk() throws Exception {
        // Given
        ObjectId playlistId = new ObjectId();
        ObjectId liveId = new ObjectId();

        // When & Then
        mockMvc.perform(delete("/playlist/" + playlistId.toString() + "/" + liveId.toString()))
                .andExpect(status().isOk());

        verify(playlistService).removeLiveFromPlaylist(playlistId, liveId);
    }
}