package com.lively.server.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Document(collection = "Playlist")
public class Playlist {
    @Id
    private String id;
    private String title;
    private String imageUrl;

    @DBRef  // 다른 컬렉션의 Live 문서를 참조
    private List<Live> lives;
}