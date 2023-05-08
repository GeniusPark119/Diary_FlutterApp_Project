import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/FriendModel.dart';
import 'package:frontend/screens/diary_list_screen.dart';
import 'package:frontend/screens/old_menu_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/info_modal.dart';
import 'package:frontend/widgets/theme.dart';

class FriendScreen extends StatefulWidget {
  final int diaryId;
  final int exchangeSituation;

  const FriendScreen(
      {Key? key, required this.diaryId, required this.exchangeSituation})
      : super(key: key);

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  late Future<List<FriendModel>> friends;
  int recieverId = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    friends = ApiService().getFriends();
  }

  Widget ChangeModal(int diaryId) {
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: Center(
            child: Text(
              '교환하시겠습니까?',
              style: TextStyle(fontSize: 16, color: Colors.white60),
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            decoration: BtnThemeGradientLine(),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    )),
                onPressed: () async {
                  late bool result;

                  if (recieverId == -1) {
                    result = await ApiService.RandomChange(widget.diaryId);
                  } else {
                    print('recieverId : $recieverId');
                    result = await ApiService.DiaryChangeBetweenFriends(
                        widget.diaryId, recieverId);
                    print('friend diary change: ${widget.diaryId}');
                  }

                  if (!mounted) return;
                  if (result) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DiaryListScreen()));
                  } else {
                    print('전송 실패');
                  }
                },
                child: Center(
                  child: Text('신청'),
                )),
          ),
        )
      ],
    );
  }

  Widget RandomDiary() {
    if (widget.exchangeSituation == 1) {
      return SizedBox(
        height: 100,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Flexible(
                  flex: 4,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 5,
                        child: Text(
                          'RANDOM',
                          style: TextStyle(fontSize: 24, color: Colors.white70),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          child: IconButton(
                              icon: Icon(Icons.info, color: Colors.white),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoModal(
                                          widget: Text(
                                            '✉ 랜덤 일기는 랜덤 친구와 일기를 교환할 수 있는 기능으로, 하루에 한 번만 보낼 수 있습니다.',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          height: 100);
                                    });
                              }),
                        ),
                      )
                    ],
                  )),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Flexible(
                flex: 3,
                child: Center(
                  child: Container(
                    width: 250,
                    height: 50,
                    decoration: BtnThemeGradient(),
                    child: ElevatedButton(
                        onPressed: () async {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => const Login(),
                          //     ));
                          print(widget.diaryId);
                          //Todo; api 먼저 보내서 오늘 랜덤 일기 교환했는지 여부 확인 후 다른 상태 Modal 띄우기
                          final bool result = await ApiService.CheckChange();

                          if (!mounted) return;

                          print(result);
                          if (result) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return InfoModal(
                                    widget: Text(
                                      '오늘은 이미 교환일기를 보냈습니다',
                                      style: TextStyle(color: Colors.white60),
                                    ),
                                    height: 140,
                                  );
                                });
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return InfoModal(
                                    widget: ChangeModal(widget.diaryId),
                                    height: 180,
                                  );
                                });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            )),
                        child: Text(
                          'SEND',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 5,
    );
  }

  Widget ChangeCheck(FriendModel friend) {
    if (widget.exchangeSituation == 1) {
      return Flexible(
          flex: 2,
          child: Container(
            width: 250,
            height: 50,
            decoration: BtnThemeGradientLine(),
            child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    recieverId = friend.friendId;
                  });
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const Login(),
                  //     ));
                  showDialog(
                      context: context,
                      builder: (context) {
                        return InfoModal(
                          widget: ChangeModal(widget.diaryId),
                          height: 180,
                        );
                      });

                  print('친구 : ${friend.friendId}');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    )),
                child: Text(
                  'SEND',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )),
          ));
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff0F2027), Color(0xff203A43), Color(0xff2C5364)],
          stops: [0.2, 0.7, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.1183,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(6.0),
            child: Container(
              color: Colors.white70,
              height: 1.0,
            ),
          ),
          title: Text('FRIENDS'),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MenuScreen()));
                    },
                    child: Image(
                      image: AssetImage(
                        'assets/img/icon_menu_page.png',
                      ),
                      width: 45,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Go frined add page');
                    },
                    child: Image(
                      image: AssetImage(
                        'assets/img/friend_icon.png',
                      ),
                      width: 45,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Text('이름을 누르면 친구와 교환한 일기를 볼 수 있습니다.', style: TextStyle(color: Colors.white70, fontSize: 12),),
                // ),
                RandomDiary(),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 5),
                  child: FutureBuilder<List<FriendModel>>(
                      future: friends,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final friend = snapshot.data![index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 5),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          'https://play-lh.googleusercontent.com/38AGKCqmbjZ9OuWx4YjssAz3Y0DTWbiM5HB0ove1pNBq_o9mtWfGszjZNxZdwt_vgHo=w240-h480-rw'),
                                    ),
                                    title: Row(children: [
                                      Flexible(
                                          flex: 3,
                                          child: SizedBox(
                                            width: 200,
                                            child: Text(
                                              friend.nickname,
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 24),
                                            ),
                                          )),
                                      ChangeCheck(friend),
                                    ]),
                                  ),
                                );
                              });
                        } else if (snapshot.hasError) {
                          print('error : ${snapshot.error}');
                        }

                        return Center(
                          child: Text(
                            '새로운 친구를 만들어보세요!',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
