package com.a101.fakediary.diary.controller;

import com.a101.fakediary.diary.dto.DiaryFilterDto;
import com.a101.fakediary.diary.dto.DiaryRequestDto;
import com.a101.fakediary.diary.dto.DiaryResponseDto;
import com.a101.fakediary.diary.service.DiaryService;
import com.a101.fakediary.friendship.dto.FriendshipDto;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@ApiOperation(value = "DiaryController")
@RequestMapping("/diary")
@RequiredArgsConstructor
public class DiaryController {

    private final DiaryService diaryService;

    @ApiOperation(value = "일기 등록")
    @PostMapping("/save")
    public ResponseEntity<?> saveDiary(@RequestBody DiaryRequestDto dto) {
        try {
            diaryService.saveDiary(dto);
            return new ResponseEntity(HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @ApiOperation(value = "일기 상세 조회")
    @GetMapping("/detail/{diaryId}")
    public ResponseEntity<?> detailDiary(@PathVariable Long diaryId) {
        try {
            DiaryResponseDto diary = diaryService.detailDiary(diaryId);
            return new ResponseEntity<DiaryResponseDto>(diary, HttpStatus.OK);
        } catch (NullPointerException e){
            return new ResponseEntity(HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @ApiOperation(value = "일기 전체 조회")
    @GetMapping("/all/{memberId}")
    public ResponseEntity<?> allDiary(@PathVariable Long memberId) {
        try {
            List<DiaryResponseDto> diary = diaryService.allDiary(memberId);
            return new ResponseEntity<List<DiaryResponseDto>>(diary, HttpStatus.OK);
        } catch (NullPointerException e){
            return new ResponseEntity(HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @ApiOperation(value = "일기 필터 조회, id: 선택한 사람 id, memberId: 조회한 사람 id, genre: 장르")
    @PostMapping("/filter")
    public ResponseEntity<?> filterDiary(@RequestBody DiaryFilterDto filter) {
        try {
            List<DiaryResponseDto> diary = diaryService.filterDiary(filter);
            return new ResponseEntity<List<DiaryResponseDto>>(diary, HttpStatus.OK);
        } catch (NullPointerException e){
            return new ResponseEntity(HttpStatus.NO_CONTENT);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @ApiOperation(value = "일기 삭제")
    @DeleteMapping("/delete/{diaryId}")
    public ResponseEntity<?> deleteDiary(@PathVariable Long diaryId) {
        try {
            diaryService.deleteDiary(diaryId);
            return new ResponseEntity(HttpStatus.OK);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}