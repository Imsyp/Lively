package com.lively.server.repository;

import com.lively.server.domain.Live;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LiveRepository extends MongoRepository<Live, ObjectId> {
}
