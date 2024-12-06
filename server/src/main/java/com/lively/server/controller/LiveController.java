package com.lively.server.controller;

import com.lively.server.domain.Live;
import com.lively.server.service.LiveService;
import org.bson.types.ObjectId;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/live")
public class LiveController {

    private final LiveService liveService;

    public LiveController(LiveService liveService) {
        this.liveService = liveService;
    }

    @PostMapping("/add")
    public ResponseEntity<Void> addLive(@RequestBody Live live) {
        liveService.saveLive(live);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Live> getLive(@PathVariable("id") String id) {
        ObjectId objectId = new ObjectId(id);
        Optional<Live> live = liveService.getLive(objectId);
        if (live.isPresent()) {  // 값이 존재하면
            return ResponseEntity.ok(live.get());
        } else {  // 값이 없으면
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping
    public List<Live> getALlLives() {
        return liveService.getAllLives();
    }

    @DeleteMapping("/{id}")
    public void deleteLive(@PathVariable("id") String id) {
        ObjectId objectId = new ObjectId(id);
        liveService.deleteLive(objectId);
    }
}
