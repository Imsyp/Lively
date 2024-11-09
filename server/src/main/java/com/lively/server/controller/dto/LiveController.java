package com.lively.server.controller.dto;

import com.lively.server.domain.Live;
import com.lively.server.service.LiveService;
import org.apache.coyote.Response;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
    public ResponseEntity<Live> getLive(@PathVariable Long id) {
        Live live = liveService.getLive(id);
        if(live != null) {
            return ResponseEntity.ok(live);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping
    public List<Live> getALlLives() {
        return liveService.getAllLives();
    }

    @DeleteMapping("/{id}")
    public void deleteLive(@PathVariable Long id) {
        liveService.deleteLive(id);
    }
}
