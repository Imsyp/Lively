package com.lively.server.service;

import com.lively.server.domain.Live;
import com.lively.server.repository.LiveRepository;
import org.bson.types.ObjectId;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class LiveService {

    private final LiveRepository liveRepository;

    public LiveService(LiveRepository liveRepository) {
        this.liveRepository = liveRepository;
    }

    public void saveLive(Live live) {
        liveRepository.save(live);
    }

    public Optional<Live> getLive(ObjectId id) {
        return liveRepository.findById(id);
    }


    public List<Live> getAllLives() {
        return liveRepository.findAll();
    }

    public void deleteLive(ObjectId id) {
        liveRepository.deleteById(id);
    }
}
