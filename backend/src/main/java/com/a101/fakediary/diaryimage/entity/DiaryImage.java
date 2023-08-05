package com.a101.fakediary.diaryimage.entity;

import com.a101.fakediary.common.BaseTimeEntity;
import com.a101.fakediary.diary.entity.Diary;
import lombok.*;

import javax.persistence.*;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "diary_image", indexes =  {@Index(name = "idx__diary", columnList = "diary")})
public class DiaryImage extends BaseTimeEntity {
    @SequenceGenerator(
            name = "DIARY_IMAGE_SEQ_GEN",
            sequenceName = "DIARY_IMAGE_SEQ",
            initialValue = 100,
            allocationSize = 1
    )


    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "DIARY_IMAGE_SEQ_GEN")
    @Id
    private Long diaryImageId;

    @ManyToOne
    @JoinColumn(name = "diary_id")
    private Diary diary;

    @Column(nullable = false)
    private String diaryImageUrl;

    @Column(nullable = false)
    private String ImagePrompt;
}
