package com.a101.fakediary.music.repository;

import com.a101.fakediary.music.dto.MusicResponseDto;
import com.a101.fakediary.music.entity.Music;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface MusicRepository extends JpaRepository<Music, Long> {

    @Query("SELECT new com.a101.fakediary.music.dto.MusicResponseDto(m)" +
            "FROM Music m WHERE m.mood = :mood")
    List<MusicResponseDto> getMusicsByMood(@Param("mood") String mood);
}
