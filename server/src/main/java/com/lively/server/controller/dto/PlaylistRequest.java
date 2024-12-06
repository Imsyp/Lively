package com.lively.server.controller.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class PlaylistRequest {
    @JsonProperty("title")
    private String title;

    @JsonProperty("imageUrl")
    private String imageUrl;
}
