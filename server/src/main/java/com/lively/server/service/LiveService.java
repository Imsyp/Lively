package com.lively.server.service;

import com.lively.server.domain.Live;
import com.lively.server.repository.LiveRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LiveService {

    private final LiveRepository liveRepository;

    public LiveService(LiveRepository liveRepository) {
        this.liveRepository = liveRepository;
    }

    public void saveLive(Live live) {
        liveRepository.save(live);
    }

    public Live getLive(Long id) {
        return liveRepository.findLiveById(id);
    }


    public List<Live> getAllLives() {
        return liveRepository.findAll();
    }

    public void deleteLive(Long id) {
        liveRepository.deleteById(id);
    }
}
