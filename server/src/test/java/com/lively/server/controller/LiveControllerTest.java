package com.lively.server.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lively.server.domain.Live;
import com.lively.server.service.LiveService;
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
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(LiveController.class)
class LiveControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LiveService liveService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void addLive_ShouldReturnCreated() throws Exception {
        // Given
        Live live = new Live();
        live.setTitle("Test Live");

        // When & Then
        mockMvc.perform(post("/live/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(live)))
                .andExpect(status().isCreated());

        verify(liveService).saveLive(any(Live.class));
    }

    @Test
    void getLive_WhenExists_ShouldReturnLive() throws Exception {
        // Given
        ObjectId id = new ObjectId();
        Live live = new Live();
        live.setTitle("Test Live");

        when(liveService.getLive(id)).thenReturn(Optional.of(live));

        // When & Then
        mockMvc.perform(get("/live/" + id.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Test Live"));
    }

    @Test
    void getLive_WhenNotExists_ShouldReturnNotFound() throws Exception {
        // Given
        ObjectId id = new ObjectId();
        when(liveService.getLive(id)).thenReturn(Optional.empty());

        // When & Then
        mockMvc.perform(get("/live/" + id.toString()))
                .andExpect(status().isNotFound());
    }

    @Test
    void getAllLives_ShouldReturnList() throws Exception {
        // Given
        List<Live> lives = Arrays.asList(
                new Live(), new Live()
        );
        when(liveService.getAllLives()).thenReturn(lives);

        // When & Then
        mockMvc.perform(get("/live"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));
    }

    @Test
    void deleteLive_ShouldCallService() throws Exception {
        // Given
        ObjectId id = new ObjectId();

        // When & Then
        mockMvc.perform(delete("/live/" + id.toString()))
                .andExpect(status().isOk());

        verify(liveService).deleteLive(id);
    }
}
