package com.a101.fakediary.soundraw.controller;

import com.a101.fakediary.soundraw.SoundRawCrawler;
import com.a101.fakediary.soundraw.dto.SoundRawRequestDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/sound-raw")
public class SoundRawTestController {
    private final SoundRawCrawler soundRawCrawler;

    @PostMapping
    public ResponseEntity<?> downloadMusic(@RequestBody SoundRawRequestDto request) {
        try {
            String musicUrl = soundRawCrawler.getMusicUrl(request.getGenreList(), request.getDiaryPk());
            return new ResponseEntity<>(musicUrl, HttpStatus.OK);
        } catch(Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
