package com.lively.server.repository;

import com.lively.server.domain.Playlist;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PlaylistRepository extends MongoRepository<Playlist, ObjectId> {
}