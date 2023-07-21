package com.a101.fakediary.card.service;

import com.a101.fakediary.card.dto.request.CardSaveRequestDto;
import com.a101.fakediary.card.dto.response.CardSaveResponseDto;
import com.a101.fakediary.card.entity.Card;
import com.a101.fakediary.card.repository.CardRepository;
import com.a101.fakediary.carddiarymapping.entity.CardDiaryMapping;
import com.a101.fakediary.carddiarymapping.repository.CardDiaryMappingRepository;
import com.a101.fakediary.deeparteffects.api.DeepArtEffectsApi;
import com.a101.fakediary.deeparteffects.styles.DeepArtEffectsStyles;
import com.a101.fakediary.diary.dto.DiaryResponseDto;
import com.a101.fakediary.diary.entity.Diary;
import com.a101.fakediary.diary.repository.DiaryRepository;
import com.a101.fakediary.diary.service.DiaryService;
import com.a101.fakediary.imagefile.handler.ImageFileHandler;
import com.a101.fakediary.member.entity.Member;
import com.a101.fakediary.member.repository.MemberRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.tomcat.util.json.JSONParser;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class CardService {
    private final CardRepository cardRepository;
    private final MemberRepository memberRepository;
    private final CardDiaryMappingRepository cardDiaryMappingRepository;
    private final ImageFileHandler s3ImageFileHandler;
    private final DeepArtEffectsApi deepArtEffectsApi;

    /**
     * 
     * @param origImageFile : 카드 촬영 후 App에서 편집되어 넘어온 사진
     * @param cardImageFileUrl : DeepArtEffects가 적용된 카드의 이미지 URL
     * @param styleIndex : 카드에 적용할 DeepArtEffects style의 index
     * @param styleId : 카드에 적용할 DeepArtEffects style의 id
     * @param saveCardDtoString : App에서 받은 요청 DTO 문자열
     * @return : 카드 저장 정보 DTO
     * @throws Exception : 예외 발생 가능
     */
    @Transactional
    public CardSaveResponseDto saveCard(MultipartFile origImageFile, String cardImageFileUrl, int styleIndex, String styleId, String saveCardDtoString) throws Exception {
        CardSaveResponseDto ret = null;
        JSONParser jsonParser = new JSONParser(saveCardDtoString);
        Object obj = jsonParser.parse();
        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> map = mapper.convertValue(obj, Map.class);
        CardSaveRequestDto saveCardDto = createCardSaveRequestDto(map);
        MultipartFile cardImageFile = ImageFileHandler.downloadImage(cardImageFileUrl);

//        log.info("cardImageFile = " + cardImageFile);

        List<Member> memberList = memberRepository.findAll();
//        log.info("memberList = " + memberList);

        Member member = memberRepository.findById(saveCardDto.getMemberId()).orElseThrow(() -> new Exception("member not found"));
        String origImageUrl = s3ImageFileHandler.uploadOnS3(origImageFile);
        String cardImageUrl = s3ImageFileHandler.uploadOnS3(cardImageFile);

        Card card = Card.builder()
                .member(member)
                .baseName(saveCardDto.getBaseName())
                .basePlace(saveCardDto.getBasePlace())
                .keyword(saveCardDto.getKeyword())
                .latitude(saveCardDto.getLatitude())
                .longitude(saveCardDto.getLongitude())
                .originCardImageName(origImageFile.getOriginalFilename())
                .origImageUrl(origImageUrl)
                .cardImageUrl(cardImageUrl)
                .cardStyleIndex(styleIndex)
                .cardStyleId(styleId)
                .build();

        if(card.getBaseName().equals("") && card.getBasePlace().equals("") && card.getKeyword().equals(""))
            throw new Exception("키워드가 존재하지 않음!!");

        cardRepository.save(card);
        ret = createCardSaveResponseDto(card);

        return ret;
    }

    /**
     * 
     * @param origImageFile : App에서 받아온 이미지 파일
     * @return : 카드 이미지로 변환하기 위해 적용된 style id와 index, 변환된 이미지의 URL 
     * @throws Exception : 예외 발생 가능
     */
    @Transactional
    public Map<String, String> getCardImageInfo(MultipartFile origImageFile) throws Exception {
        Map<String, String> ret = new HashMap<>();

        int randomStyleIdx = DeepArtEffectsStyles.getRandomStyleIdx();
        String styleId = DeepArtEffectsStyles.getStyleId(randomStyleIdx);   //  적용된 styleId

        String submissionId = deepArtEffectsApi.uploadImageWithStyleId(origImageFile, styleId);

//        log.info("submissionId = " + submissionId);

        String cardImageFileUrl = deepArtEffectsApi.getCardImageUrl(submissionId);  //  카드 이미지 URL

        ret.put("styleIndex", String.valueOf(randomStyleIdx));
        ret.put("styleId", styleId);
        ret.put("cardImageFileUrl", cardImageFileUrl);

        return ret;
    }

    @Transactional(readOnly = true)
    public List<CardSaveResponseDto> listCards(Long memberId) throws Exception {
        List<CardSaveResponseDto> ret  = new ArrayList<>();

        List<Card> cardList = cardRepository.findAllByMemberId(memberId).orElseThrow(() -> new Exception("Card of member not found"));
        for (Card card : cardList) {
            ret.add(createCardSaveResponseDto(card));
        }

        return ret;
    }

    @Transactional(readOnly = true)
    public CardSaveResponseDto findCard(Long cardId) throws Exception {
        CardSaveResponseDto ret = null;

        Card card = cardRepository.findById(cardId).orElseThrow(() -> new Exception("Card not found"));
        ret = createCardSaveResponseDto(card);

        return ret;
    }

    @Transactional
    public Long deleteCardByCardId(Long cardId) throws Exception {
        Card card = cardRepository.findById(cardId).orElseThrow(() -> new Exception("Card not found"));
        Long ret = card.getCardId();

        cardRepository.delete(card);
        return ret;
    }

    //특정 카드로 만들어진 일기Id 리스트 반환
    @Transactional(readOnly = true)
    public List<Long> getDiaryIdsByCardId(Long cardId) {
        return cardDiaryMappingRepository.findDiaryIdsByCardId(cardId);
    }
    private CardSaveRequestDto createCardSaveRequestDto(Map<String, Object> map) {
        Object baseNameObj = map.get("baseName");
        Object basePlaceObj = map.get("basePlace");
        Object latitudeObj = map.get("latitude");
        Object longitudeObj = map.get("longitude"); //  nullable한 속성들

        log.info("memberId = " + map.get("memberId"));
        log.info("baseName = " + baseNameObj);
        log.info("basePlace = " + basePlaceObj);
        log.info("keyword = " + map.get("keyword"));
        log.info("latitude = " + latitudeObj);
        log.info("longitude = " + longitudeObj);

        Long memberId = Long.parseLong(String.valueOf(map.get("memberId")));
        String baseName = baseNameObj != null ? String.valueOf(baseNameObj) : null;
        String basePlace = basePlaceObj != null ? String.valueOf(basePlaceObj) : null;
        String keyword = String.valueOf(map.get("keyword"));
        BigDecimal latitude = latitudeObj != null ? new BigDecimal(String.valueOf(latitudeObj)) : null;
        BigDecimal longitude = longitudeObj != null ? new BigDecimal(String.valueOf(longitudeObj)) : null;

        return CardSaveRequestDto.builder()
                .memberId(memberId)
                .baseName(baseName)
                .basePlace(basePlace)
                .keyword(keyword)
                .latitude(latitude)
                .longitude(longitude)
                .build();
    }

    private CardSaveResponseDto createCardSaveResponseDto(Card card) {
        Member member = card.getMember();

        CardSaveResponseDto ret = CardSaveResponseDto.builder()
                .cardId(card.getCardId())
                .memberId(member.getMemberId())
                .nickName(member.getNickname())
                .baseName(card.getBaseName())
                .basePlace(card.getBasePlace())
                .keywords(new ArrayList<>())
                .cardImageUrl(card.getCardImageUrl())
                .createdAt(card.getCreatedAt())
                .build();

        StringTokenizer tokens = new StringTokenizer(card.getKeyword(), "@");
        while(tokens.hasMoreTokens()) {
            ret.getKeywords().add(tokens.nextToken());
        }

        return ret;
    }
}
