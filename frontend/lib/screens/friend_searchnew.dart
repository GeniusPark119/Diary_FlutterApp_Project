import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/model/SearchFriendModel.dart';
import 'package:frontend/services/api_service.dart';
import 'package:lottie/lottie.dart';

// import 'search_friend_model.dart'; // Replace this with the appropriate model file

const baseUrl =
    'https://example.com/api'; // Replace this with your API base URL

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Demo',
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchFriendModel> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String searchText) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<SearchFriendModel> results =
          await ApiService().getSearchFriends(searchText);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buttonAdd(senderID) {
    return GestureDetector(
        onTap: () async {
          bool isSended = await ApiService.AddFriend(senderID);
          isSended
              ? ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(child: Text('친구요청 완료!')),
                  ),
                )
              : ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(child: Text('이미 친구 요청 했짜나 ㅠ')),
                  ),
                );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              child: Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xff79F1A4),
                      Color(0xff0E5CAD),
                    ]),
                    borderRadius: BorderRadius.circular(25)),
                child: Center(
                    child: Text(
                  '친구 요청',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )),
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/background_pink_darken.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('친구 검색'),
          ),
          body: SingleChildScrollView(
              child: Column(
            children: [
              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '닉네임을 검색하세요',
                    hintStyle: TextStyle(
                      color: Colors.blue[100],
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        _onSearch(_searchController.text);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: 330,
                height: 400,
                padding: EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white,
                    width: 0.2,
                  ),
                ),
                child: Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _searchResults.isNotEmpty
                          ? ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (BuildContext context, int index) {
                                SearchFriendModel friend =
                                    _searchResults[index];
                                return Center(
                                    child: Column(
                                  children: [
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/svg/atronaut-svgrepo-com.svg',
                                          semanticsLabel: 'user',
                                          width: 40,
                                          height: 40,
                                        ),

                                        Text(
                                          friend.nickname.toString(),
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.white),
                                        ),
                                        Expanded(
                                            child: _buttonAdd(friend.memberId)),
                                        SizedBox(width: 8),
                                        // 각 위젯 사이에 간격을 주기 위해 SizedBox를 사용합니다.
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 0.2,
                                      color: Colors.white,
                                    )
                                  ],
                                ));
                              },
                            )
                          : Center(
                              child: Text(
                              '해당 친구는 존재하지 않아요!',
                              style: TextStyle(
                                color: Colors.blue[100],
                              ),
                            )),
                ),
              ),
              Center(
                child: Lottie.asset('assets/lottie/stars.json', height: 120),
              ),
            ],
          ))),
    );
  }
}
