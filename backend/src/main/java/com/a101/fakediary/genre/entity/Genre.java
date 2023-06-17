package com.a101.fakediary.genre.entity;

import com.a101.fakediary.common.BaseTimeEntity;
import lombok.*;

import javax.persistence.*;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "genre")
public class Genre extends BaseTimeEntity {
   @EmbeddedId
   private GenrePK id;
}
