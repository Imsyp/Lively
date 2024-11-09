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