package com.a101.fakediary.friendship.service;

import com.a101.fakediary.friendship.dto.FriendshipDto;
import com.a101.fakediary.friendship.dto.FriendshipResponseDto;
import com.a101.fakediary.friendship.entity.Friendship;
import com.a101.fakediary.friendship.repository.FriendshipRepository;
import com.a101.fakediary.member.entity.Member;
import com.a101.fakediary.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class FriendshipService {

    private final FriendshipRepository friendshipRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public void saveFriend(FriendshipDto dto) {
        friendshipRepository.save(dto.toEntity());
    }

    @Transactional
    public void deleteFriend(FriendshipDto dto) {
        Long memberId = dto.getMemberId();
        Long friendId = dto.getFriendId();
        friendshipRepository.deleteFriend(memberId, friendId);
    }

    @Transactional(readOnly = true)
    public List<Member> searchFriend(String nickname, Long memberId) {
        return friendshipRepository.searchFriend(nickname, memberId);
    }

    @Transactional(readOnly = true)
    public List<FriendshipResponseDto> listFriend(Long memberId) {
        return friendshipRepository.listFriend(memberId);
    }
}
