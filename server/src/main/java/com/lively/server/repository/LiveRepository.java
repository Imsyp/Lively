package com.lively.server.repository;

import com.lively.server.domain.Live;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LiveRepository extends JpaRepository<Live, Long> {
    Live findLiveById(Long id);
}
