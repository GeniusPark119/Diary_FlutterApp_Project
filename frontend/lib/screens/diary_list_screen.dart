import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'menu_screen.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({Key? key}) : super(key: key);

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
            0.3,
            0.6,
            0.9
          ],
              colors: [
            Color(0xff0f2027),
            Color(0xff203a43),
            Color(0xff2c5364),
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: MediaQuery.of(context).size.height * 0.1183,
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    ],
                  ),
                )
              ],
            )
          ],
        ),
        body: Column(
          children: [
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Flexible(flex: 4,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/img/diary_list.png'))),
                      ),
                    ),
                  )),
                  Flexible(flex: 2, child: Container(
                    child: Column(
                      children: [
                        Flexible(flex: 1, child: Container(),),
                        Flexible(flex: 1, child: Row(
                          children: [
                            Flexible(flex: 2, child: Container(),),
                            Flexible(flex: 6, child: Text('내가 만든 일기를 확인해보세요', style: TextStyle(color: Colors.white),)),
                            Flexible(flex: 2, child: Row(

                              children: [
                                Flexible(flex: 1, child: Container(),),
                                Flexible(flex: 1, child: Container(
                                decoration: BoxDecoration(color: Colors.white),
                              ),),
                                Flexible(flex: 1, child: Container(),)],
                            )),
                          ],
                        )),
                      ],
                    ),
                  ),),
                ],
              )
            ),
            Flexible(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(color: Colors.yellow),
                ))
          ],
        ),
      ),
    );
  }
}
