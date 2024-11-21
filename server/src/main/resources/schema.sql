CREATE TABLE LIVE (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    singer VARCHAR(255) NOT NULL,
    description TEXT,                  -- 설명 필드
    lyrics TEXT,                       -- 가사 필드
    thumbnail_url VARCHAR(255),        -- 썸네일 URL 필드
    start_time DOUBLE NOT NULL,
    end_time DOUBLE NOT NULL,
    video_id VARCHAR(255) NOT NULL     -- 비디오 ID 필드
);

-- Playlist 테이블 생성
CREATE TABLE IF NOT EXISTS playlist (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    image_url VARCHAR(255)
);

-- Playlist와 Live의 다대다 관계를 위한 연결 테이블
CREATE TABLE IF NOT EXISTS playlist_live (
    playlist_id BIGINT,
    live_id BIGINT,
    FOREIGN KEY (playlist_id) REFERENCES playlist(id),
    FOREIGN KEY (live_id) REFERENCES live(id),
    PRIMARY KEY (playlist_id, live_id)
);

-- 샘플 데이터 추가
INSERT INTO playlist (title, image_url) VALUES
('인디 플리', 'assets/placeholder.jpg'),
('킬링보이스 플리', 'assets/placeholder.jpg'),
('콘서트 라이브 플리', 'assets/placeholder.jpg'),
('비긴어게인 플리', 'assets/placeholder.jpg'),
('버스킹 플리', 'assets/placeholder.jpg'),
('유스케 플리', 'assets/placeholder.jpg');