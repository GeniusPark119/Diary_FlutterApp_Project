import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/theme.dart';

import '../model/CardModel.dart';
import '../screens/diary_create_cards.dart';

class CardModal extends StatelessWidget {
  //모달창 class
  final CardModel card;
  final String cardTitle;

  const CardModal({Key? key, required this.card, required this.cardTitle})
      : super(key: key);

  Widget Character() {
    if (card.baseName == '') {
      return Flexible(flex: 1, child: Container(),);
    } else {
      return Flexible(
          flex: 1,
          child: Center(
            child: Row(
              children: [
                Text(
                  '주인공 : ',
                  style: TextStyle(color: Colors.white),
                ),
                Text(card.baseName, style: TextStyle(color: Colors.white)),
              ],
            ),
          ));
    }
  }

  Widget Place() {
    if (card.basePlace == '') {
      return Flexible(flex: 1, child: Container(),);
    } else {
      return Flexible(
          flex: 1,
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '장소 :',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 5,),
                  Expanded(child: Text(card.basePlace, style: TextStyle(color: Colors.white)),)
                ],
              ));
    }
  }

  Widget Kewyords() {
    if (card.keywords.isEmpty) {
      return Container();
    } else {
      String keywords = card.keywords.join(', ');
      return Flexible(
          flex: 1,
          child: Center(
              child: Column(
                children: [
                  Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            decoration: BtnThemeGradientLine(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
                              child: Text(
                                '키워드',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      )),
                  Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child:
                        Text(keywords, style: TextStyle(color: Colors.white)),
                      ))
                ],
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('cardId : ${card.cardId}');
    print('here???');
    return Container(
        decoration: BgThemeIncludeImage(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title:
            Text(cardTitle, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          body: Padding(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Text(
                      '기억의 조각이 완성된 날',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Flexible(
                    flex: 1,
                    child: Text(
                      card.createdAt.split('T')[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Flexible(
                    flex: 11,
                    child: Center(
                      child: Row(
                        children: [
                          Flexible(
                              flex: 1,
                              child: Container(
                                width: MediaQuery.of(context).size.width/3,
                                height:  (MediaQuery.of(context).size.width/3)*1.35,
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                                  border: Border.all(
                                      color: Colors.white60, width: 4),
                                  image: DecorationImage(
                                      image: NetworkImage(card.cardImageUrl),
                                      fit: BoxFit.cover),
                                ),
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          Flexible(
                              flex: 1,
                              child: SizedBox(
                                width: 200,
                                height: 240,
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Character(),
                                        Place(),
                                        Kewyords()
                                      ],
                                    )),
                              )),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiaryCreateCards(
                                    cardIdFromList: card.cardId),
                              ));
                        },
                        child: Center(
                          child: Container(
                            width: 400,
                            height: 50,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Color(0xff79F1A4),
                                  Color(0xff0E5CAD),
                                ]),
                                borderRadius: BorderRadius.circular(25)),
                            child: Center(
                                child: Text(
                                  '일기생성',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                                )),
                          ),
                        )),
                  )
                ],
              )),
        ));
  }
}