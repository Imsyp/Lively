package com.lively.server.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Document(collection = "Live")
public class Live {

    @Id
    private String id;

    private String title;
    private String singer;
    private String description;
    private String lyrics;
    private String thumbnailUrl;
    private double startTime;
    private double endTime;
    private String videoId;
}
